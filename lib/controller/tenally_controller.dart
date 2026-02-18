// ignore_for_file: prefer_const_constructors, avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../Api/config.dart';
import '../Api/data_store.dart';
import '../screen/tenally/submission_success_screen.dart';

class TenallyController extends GetxController {
  final GlobalKey<FormState> scriptFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> artistFormKey = GlobalKey<FormState>();

  final TextEditingController scriptNameController = TextEditingController();
  final TextEditingController scriptEmailController = TextEditingController();
  final TextEditingController scriptTitleController = TextEditingController();

  final TextEditingController artistNameController = TextEditingController();
  final TextEditingController artistEmailController = TextEditingController();

  final List<String> roleOptions = [
    "Actor",
    "Singer",
    "Dancer",
    "Choreographer",
    "Musician",
    "Other"
  ];

  String? selectedRole;
  XFile? selectedScriptFile;
  bool isScriptSubmitting = false;
  bool isArtistSubmitting = false;
  double scriptUploadProgress = 0;
  bool scriptUploadCompleted = false;
  String? uploadedScriptFileName;

  String? get scriptFileName => selectedScriptFile?.name;

  String get _userId =>
      (getData.read("UserLogin") != null ? getData.read("UserLogin")["id"] : "0")
          .toString();

  Future<void> pickScriptFile() async {
    final typeGroup = XTypeGroup(label: 'scripts', extensions: ['pdf', 'doc', 'docx']);
    final XFile? result = await openFile(acceptedTypeGroups: [typeGroup]);
    if (result == null) return;
    selectedScriptFile = result;
    uploadedScriptFileName = null;
    scriptUploadProgress = 0;
    scriptUploadCompleted = false;
    update();
  }

  Future<void> submitScript() async {
    if (isScriptSubmitting) return;
    if (scriptFormKey.currentState?.validate() != true) return;
    if (selectedScriptFile == null) {
      Get.snackbar("Script file", "Please select a script file to upload.");
      return;
    }

    final filePath = selectedScriptFile?.path;
    if (filePath == null || filePath.isEmpty) {
      Get.snackbar("Script file", "Unable to read the selected file.");
      return;
    }

    isScriptSubmitting = true;
    scriptUploadProgress = 0;
    scriptUploadCompleted = false;
    update();
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(Config.baseurl + Config.tenallyScriptSubmit),
      );
      request.fields['name'] = scriptNameController.text.trim();
      request.fields['email'] = scriptEmailController.text.trim();
      request.fields['script_title'] = scriptTitleController.text.trim();
      request.fields['user_id'] = _userId;

      final file = File(filePath);
      final fileLength = await file.length();
      int bytesSent = 0;
      final byteStream = file.openRead().transform(
        StreamTransformer<List<int>, List<int>>.fromHandlers(
          handleData: (chunk, sink) {
            bytesSent += chunk.length;
            scriptUploadProgress = (bytesSent / fileLength).clamp(0, 1);
            update();
            sink.add(chunk);
          },
          handleError: (error, stackTrace, sink) {
            sink.addError(error, stackTrace);
          },
          handleDone: (sink) {
            sink.close();
          },
        ),
      );

      final scriptFile = http.MultipartFile(
        'script_file',
        byteStream,
        fileLength,
        filename: selectedScriptFile!.name,
      );
      request.files.add(scriptFile);

      final streamed = await request.send();
      final body = await streamed.stream.bytesToString();
      if (streamed.statusCode == 200) {
        final response = jsonDecode(body);
        final code = response["ResponseCode"]?.toString();
        final message = response["ResponseMsg"]?.toString() ?? "Submitted";
        if (code == "200") {
          final uploadedName = selectedScriptFile?.name;
          _clearScriptForm(preserveFile: true);
          uploadedScriptFileName = uploadedName;
          scriptUploadCompleted = true;
          scriptUploadProgress = 1;
          update();
          Get.to(() => SubmissionSuccessScreen(
                submissionType: SubmissionType.script,
                message: message,
                fileName: uploadedScriptFileName,
              ));
          return;
        } else {
          scriptUploadProgress = 0;
          scriptUploadCompleted = false;
          Get.snackbar("Script submission", message,
              backgroundColor: Colors.red.withOpacity(0.1),
              colorText: Colors.red);
        }
      } else {
        scriptUploadProgress = 0;
        scriptUploadCompleted = false;
        Get.snackbar("Script submission", "Server error (${streamed.statusCode})");
      }
    } catch (e) {
      scriptUploadProgress = 0;
      scriptUploadCompleted = false;
      Get.snackbar("Script submission", e.toString());
    } finally {
      isScriptSubmitting = false;
      update();
    }
  }

  Future<void> submitArtist() async {
    if (artistFormKey.currentState?.validate() != true) return;
    if (selectedRole == null || selectedRole!.isEmpty) {
      Get.snackbar("Role", "Please select the role you are interested in.");
      return;
    }

    isArtistSubmitting = true;
    update();
    try {
      final payload = {
        "user_id": _userId,
        "name": artistNameController.text.trim(),
        "email": artistEmailController.text.trim(),
        "role": selectedRole!,
      };

      final headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

      final response = await http.post(
        Uri.parse(Config.baseurl + Config.tenallyArtistSubmit),
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final code = data["ResponseCode"]?.toString();
        final message = data["ResponseMsg"]?.toString() ?? "Submitted";
        if (code == "200") {
          final currentRole = selectedRole;
          _clearArtistForm();
          Get.to(() => SubmissionSuccessScreen(
                submissionType: SubmissionType.artist,
                message: message,
                fileName: currentRole,
              ));
          return;
        } else {
          Get.snackbar("Artist submission", message,
              backgroundColor: Colors.red.withOpacity(0.1),
              colorText: Colors.red);
        }
      } else {
        Get.snackbar("Artist submission", "Server error (${response.statusCode})");
      }
    } catch (e) {
      Get.snackbar("Artist submission", e.toString());
    } finally {
      isArtistSubmitting = false;
      update();
    }
  }

  void _clearScriptForm({bool preserveFile = false}) {
    scriptNameController.clear();
    scriptEmailController.clear();
    scriptTitleController.clear();
    if (!preserveFile) {
      selectedScriptFile = null;
      uploadedScriptFileName = null;
      scriptUploadProgress = 0;
      scriptUploadCompleted = false;
    } else {
      selectedScriptFile = null;
    }
    update();
  }

  void removeScriptFile() {
    selectedScriptFile = null;
    uploadedScriptFileName = null;
    scriptUploadProgress = 0;
    scriptUploadCompleted = false;
    update();
  }

  void _clearArtistForm() {
    artistNameController.clear();
    artistEmailController.clear();
    selectedRole = null;
    update();
  }

  @override
  void onClose() {
    scriptNameController.dispose();
    scriptEmailController.dispose();
    scriptTitleController.dispose();
    artistNameController.dispose();
    artistEmailController.dispose();
    super.onClose();
  }
}
