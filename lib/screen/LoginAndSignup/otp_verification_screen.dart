// ignore_for_file: use_key_in_widget_constructors, prefer_const_literals_to_create_immutables

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controller/auth_controller.dart';
import '../../model/fontfamily_model.dart';
import '../../utils/Colors.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({Key? key}) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final AuthController _authController = Get.find();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Widget _buildOtpCell(String digit, bool isActive, double width) {
    return Container(
      width: width,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? gradient.defoultColor : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        digit,
        style: const TextStyle(
          fontSize: 22,
          fontFamily: FontFamily.gilroyBold,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final phoneDisplay = _authController.otpDisplayPhone;
    return Scaffold(
      backgroundColor: WhiteColor,
      appBar: AppBar(
        backgroundColor: WhiteColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: BlackColor),
        title: Text(
          "Verification Code".tr,
          style: const TextStyle(
            fontFamily: FontFamily.gilroyBold,
            fontSize: 18,
            color: BlackColor,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${"We have sent the code verification to".tr}\n$phoneDisplay",
              style: TextStyle(
                fontFamily: FontFamily.gilroyMedium,
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 30),
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 8.0;
                final totalSpacing = spacing * 5;
                final availableWidth =
                    math.max(constraints.maxWidth - totalSpacing, 0);
                final cellWidth = math.min(availableWidth / 6, 60.0);
                return ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _authController.otpController,
                  builder: (context, value, _) {
                    final input = value.text;
                    final digits = input.length > 6
                        ? input.substring(0, 6)
                        : input;
                    return GestureDetector(
                      onTap: () => _focusNode.requestFocus(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(6, (index) {
                          final digit =
                              index < digits.length ? digits[index] : '';
                          final isActive =
                              index == digits.length && digits.length < 6;
                          return Padding(
                            padding: EdgeInsets.only(
                              right: index == 5 ? 0 : spacing,
                            ),
                            child: _buildOtpCell(
                              digit,
                              isActive,
                              cellWidth,
                            ),
                          );
                        }),
                      ),
                    );
                  },
                );
              },
            ),
            Offstage(
              offstage: true,
              child: TextField(
                focusNode: _focusNode,
                controller: _authController.otpController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                ),
                cursorColor: gradient.defoultColor,
                enableInteractiveSelection: false,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.oneTimeCode],
              ),
            ),
            const SizedBox(height: 16),
            GetBuilder<AuthController>(
              builder: (controller) {
                final disableResend =
                    controller.resendCooldownSeconds > 0 ||
                    controller.isOtpProcessing;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive code?".tr,
                      style: TextStyle(
                        fontFamily: FontFamily.gilroyMedium,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (controller.resendCooldownSeconds > 0)
                      Text(
                        "${controller.resendCooldownSeconds} Seconds".tr,
                        style: TextStyle(
                          fontFamily: FontFamily.gilroyBold,
                          color: gradient.defoultColor,
                        ),
                      )
                    else
                      TextButton(
                        onPressed:
                            disableResend ? null : () => controller.resendOtp(),
                        style:
                            TextButton.styleFrom(foregroundColor: gradient.defoultColor),
                        child: controller.isOtpResending
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "Resend OTP".tr,
                                style: const TextStyle(
                                  fontFamily: FontFamily.gilroyBold,
                                ),
                              ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),
            GetBuilder<AuthController>(
              builder: (controller) {
                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: controller.isOtpProcessing
                        ? null
                        : () => controller.verifyOtp(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gradient.defoultColor,
                      foregroundColor: WhiteColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isOtpProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: WhiteColor,
                            ),
                          )
                        : Text(
                            "Verify".tr,
                            style: const TextStyle(
                              fontFamily: FontFamily.gilroyBold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
