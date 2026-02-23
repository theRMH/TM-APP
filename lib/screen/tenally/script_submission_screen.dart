// ignore_for_file: prefer_const_constructors, file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/tenally_controller.dart';
import '../../model/fontfamily_model.dart';
import '../../utils/Colors.dart';

class TenallyScriptSubmissionScreen extends StatelessWidget {
  final TenallyController controller = Get.put(TenallyController());

  TenallyScriptSubmissionScreen({super.key});

  OutlineInputBorder get _inputBorder => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: gradient.defoultColor, width: 1),
      );

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TenallyController>(
      init: controller,
      builder: (ctrl) {
        final hasFile =
            ctrl.selectedScriptFile != null || ctrl.uploadedScriptFileName != null;
        final buttonLabel = ctrl.selectedScriptFile != null
            ? "Change file"
            : (ctrl.uploadedScriptFileName != null
                ? "Replace uploaded file"
                : "Select file (.pdf/.doc/.docx)");

        return Scaffold(
          appBar: AppBar(
            backgroundColor: WhiteColor,
            iconTheme: IconThemeData(color: BlackColor),
            title: Text(
              "Script Submission",
              style: TextStyle(
                fontFamily: FontFamily.gilroyBold,
                color: BlackColor,
              ),
            ),
          ),
          backgroundColor: bgcolor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: WhiteColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(18),
                child: Form(
                  key: ctrl.scriptFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: "Name",
                        controller: ctrl.scriptNameController,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        label: "Email",
                        controller: ctrl.scriptEmailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        label: "Script Title",
                        controller: ctrl.scriptTitleController,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Upload Script",
                        style: TextStyle(
                          fontFamily: FontFamily.gilroyMedium,
                          fontSize: 14,
                          color: Greycolor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: ctrl.pickScriptFile,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: gradient.defoultColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          buttonLabel,
                          style: TextStyle(
                            color: gradient.defoultColor,
                            fontFamily: FontFamily.gilroyMedium,
                          ),
                        ),
                      ),
                      if (hasFile) ...[
                        const SizedBox(height: 12),
                        _buildFilePreview(ctrl),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: gradient.defoultColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: ctrl.isScriptSubmitting
                              ? null
                              : ctrl.submitScript,
                          child: ctrl.isScriptSubmitting
                              ? const CircularProgressIndicator(
                                  color: WhiteColor,
                                  strokeWidth: 2,
                                )
                              : Text(
                                  "Submit Script",
                                  style: TextStyle(
                                    fontFamily: FontFamily.gilroyBold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Script Submission",
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            fontSize: 18,
            color: BlackColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Submit your 12-minute masterpiece.",
          style: TextStyle(
            fontFamily: FontFamily.gilroyMedium,
            fontSize: 13,
            color: Greycolor,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: FontFamily.gilroyMedium,
            fontSize: 13,
            color: Greycolor,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            fontFamily: FontFamily.gilroyMedium,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: "Enter $label",
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            border: _inputBorder,
            enabledBorder: _inputBorder,
            focusedBorder: _inputBorder,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "$label is required";
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFilePreview(TenallyController ctrl) {
    final fileName = ctrl.selectedScriptFile?.name ?? ctrl.uploadedScriptFileName;
    if (fileName == null) return const SizedBox.shrink();
    final statusLabel = ctrl.isScriptSubmitting
        ? "Uploading..."
        : (ctrl.scriptUploadCompleted ? "Uploaded" : "File selected");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xfff5f7ff),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: gradient.defoultColor.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.insert_drive_file,
                color: gradient.defoultColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: TextStyle(
                        fontFamily: FontFamily.gilroyMedium,
                        fontSize: 14,
                        color: BlackColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontFamily: FontFamily.gilroyMedium,
                        fontSize: 12,
                        color: Greycolor,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: ctrl.removeScriptFile,
                icon: Icon(
                  Icons.close,
                  color: Colors.redAccent,
                ),
              )
            ],
          ),
        ),
        if (ctrl.isScriptSubmitting)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: ctrl.scriptUploadProgress,
                  color: gradient.defoultColor,
                  backgroundColor: gradient.defoultColor.withOpacity(0.2),
                ),
                const SizedBox(height: 4),
                Text(
                  "${(ctrl.scriptUploadProgress * 100).clamp(0, 100).toStringAsFixed(0)}% uploaded",
                  style: TextStyle(
                    fontFamily: FontFamily.gilroyMedium,
                    fontSize: 12,
                    color: Greycolor,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
