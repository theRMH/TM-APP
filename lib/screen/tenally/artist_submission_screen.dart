// ignore_for_file: prefer_const_constructors, file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/tenally_controller.dart';
import '../../model/fontfamily_model.dart';
import '../../utils/Colors.dart';

class TenallyArtistSubmissionScreen extends StatelessWidget {
  final TenallyController controller = Get.put(TenallyController());

  TenallyArtistSubmissionScreen({super.key});

  OutlineInputBorder get _inputBorder => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: gradient.defoultColor, width: 1),
      );

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TenallyController>(
      init: controller,
      builder: (ctrl) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: WhiteColor,
            iconTheme: IconThemeData(color: BlackColor),
            title: Text(
              "Artist Submission",
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
                  color: const Color(0xff0b142b),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: gradient.defoultColor.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(18),
                child: Form(
                  key: ctrl.artistFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: "Name",
                        controller: ctrl.artistNameController,
                        labelColor: WhiteColor,
                        hintColor: Colors.white54,
                        textColor: WhiteColor,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        label: "Email",
                        controller: ctrl.artistEmailController,
                        keyboardType: TextInputType.emailAddress,
                        labelColor: WhiteColor,
                        hintColor: Colors.white54,
                        textColor: WhiteColor,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: ctrl.selectedRole,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                          labelText: "Role interested in",
                          labelStyle: TextStyle(
                              fontFamily: FontFamily.gilroyMedium,
                              color: WhiteColor),
                          border: _inputBorder,
                          enabledBorder: _inputBorder,
                          focusedBorder: _inputBorder,
                        ),
                        dropdownColor: const Color(0xff0b142b),
                        items: ctrl.roleOptions
                            .map(
                              (role) => DropdownMenuItem<String>(
                                value: role,
                                child: Text(
                                  role,
                                  style: TextStyle(
                                      fontFamily: FontFamily.gilroyMedium,
                                      color: WhiteColor),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          ctrl.selectedRole = value;
                          ctrl.update();
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Select a role";
                          }
                          return null;
                        },
                      ),
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
                          onPressed: ctrl.isArtistSubmitting
                              ? null
                              : ctrl.submitArtist,
                          child: ctrl.isArtistSubmitting
                              ? const CircularProgressIndicator(
                                  color: WhiteColor,
                                  strokeWidth: 2,
                                )
                              : Text(
                                  "Submit Profile",
                                  style: TextStyle(
                                    fontFamily: FontFamily.gilroyBold,
                                    fontSize: 16,
                                    color: BlackColor,
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
          "Artist Registration",
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            fontSize: 18,
            color: WhiteColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Join the crew for Season 4.",
          style: TextStyle(
            fontFamily: FontFamily.gilroyMedium,
            fontSize: 13,
            color: WhiteColor.withOpacity(0.75),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    Color? hintColor,
    Color? textColor,
    Color? labelColor,
  }) {
    final resolvedHintColor = hintColor ?? Colors.black45;
    final resolvedTextColor = textColor ?? BlackColor;
    final resolvedLabelColor = labelColor ?? Greycolor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: FontFamily.gilroyMedium,
            fontSize: 13,
            color: resolvedLabelColor,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            fontFamily: FontFamily.gilroyMedium,
            fontSize: 15,
            color: resolvedTextColor,
          ),
          decoration: InputDecoration(
            hintText: "Enter $label",
            hintStyle: TextStyle(color: resolvedHintColor),
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
}
