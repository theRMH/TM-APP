// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings, unused_local_variable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../Api/config.dart';
import '../Api/data_store.dart';
import '../firebase/auth_firebase.dart';
import '../screen/bottombar_screen.dart';
import '../utils/Custom_widget.dart';

/// Manages the simplified login/signup flow used by the new themed screens.
class AuthController extends GetxController {
  final FirebaseAuthService firebaseAuthService = Get.put(FirebaseAuthService());

  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController number = TextEditingController();
  final TextEditingController password = TextEditingController();

  bool showPassword = true;

  void togglePasswordVisibility() {
    showPassword = !showPassword;
    update();
  }

  Future<void> login({required String countryCode}) async {
    try {
      final uri = Uri.parse(Config.baseurl + Config.loginApi);
      final payload = {
        "mobile": number.text.trim(),
        "ccode": countryCode,
        "password": password.text.trim(),
      };
      final response = await http.post(uri, body: jsonEncode(payload));
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        showToastMessage(result["ResponseMsg"] ?? "Unexpected response");
        if (result["Result"] == "true") {
          await _storeUser(result["UserLogin"]);
          _resetFields();
          Get.offAll(BottomBarScreen());
        }
      } else {
        showToastMessage("Server error (${response.statusCode}).");
      }
    } catch (e) {
      print(e);
      showToastMessage("Unable to login. Please try again.");
    }
  }

  Future<void> signUp({required String countryCode}) async {
    try {
      final uri = Uri.parse(Config.baseurl + Config.registerUser);
      final payload = {
        "name": name.text.trim(),
        "email": email.text.trim(),
        "mobile": number.text.trim(),
        "ccode": countryCode,
        "password": password.text.trim(),
      };
      final response = await http.post(uri, body: jsonEncode(payload));
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        showToastMessage(result["ResponseMsg"] ?? "Unexpected response");
        if (result["Result"] == "true") {
          await _storeUser(result["UserLogin"]);
          _resetFields();
          Get.offAll(BottomBarScreen());
        }
      } else {
        showToastMessage("Server error (${response.statusCode}).");
      }
    } catch (e) {
      print(e);
      showToastMessage("Unable to register. Please try again.");
    }
  }

  Future<void> _storeUser(Map<String, dynamic>? userData) async {
    if (userData == null) return;
    save('Firstuser', true);
    save("UserLogin", userData);
    OneSignal.User.addTagWithKey("user_id", userData["id"]);
    firebaseAuthService.singInAndStoreData(
      uid: userData["id"],
      name: userData["name"],
      email: userData["email"],
      number: userData["mobile"],
      proPicPath: userData["pro_pic"] ?? "",
    );
    update();
  }

  void _resetFields() {
    name.clear();
    email.clear();
    number.clear();
    password.clear();
  }
}
