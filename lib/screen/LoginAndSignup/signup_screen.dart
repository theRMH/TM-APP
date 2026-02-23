// ignore_for_file: prefer_const_constructors, avoid_print, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../controller/auth_controller.dart';
import '../../model/fontfamily_model.dart';
import '../../screen/bottombar_screen.dart';
import '../../utils/Colors.dart';
import '../../utils/Custom_widget.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = Get.find();
  String _countryCode = "+91";
  int _selectedNavIndex = 0;

  void _onNavTap(int index) {
    setState(() {
      _selectedNavIndex = index;
    });
    if (index != 3) {
      Get.offAll(() => const BottomBarScreen());
    }
  }

  void _submit() {
    if (_authController.isSendingOtp) {
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      _authController.startPhoneAuthentication(
        countryCode: _countryCode,
        isSignUp: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: BlackColor),
                      onPressed: () => Get.back(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Create Account".tr,
                      style: TextStyle(
                        fontFamily: FontFamily.gilroyBold,
                        fontSize: 32,
                        color: BlackColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Sign up to continue".tr,
                  style: TextStyle(
                    fontFamily: FontFamily.gilroyMedium,
                    fontSize: 16,
                    color: greytext,
                  ),
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _authController.name,
                        decoration: InputDecoration(
                          labelText: "Full Name".tr,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter your name".tr;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _authController.email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Email".tr,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter your email".tr;
                          }
                          if (!GetUtils.isEmail(value.trim())) {
                            return "Please enter a valid email".tr;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      IntlPhoneField(
                        controller: _authController.number,
                        initialCountryCode: 'IN',
                        disableLengthCheck: true,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                          labelText: "Phone number".tr,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) {
                          _countryCode = value.countryCode;
                        },
                      ),
                      const SizedBox(height: 16),
                      GetBuilder<AuthController>(
                        builder: (controller) {
                          return TextFormField(
                            controller: controller.password,
                            obscureText: controller.showPassword,
                            decoration: InputDecoration(
                              labelText: "Password".tr,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.showPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: controller.togglePasswordVisibility,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your password".tr;
                              }
                              if (value.length < 6) {
                                return "Password must be at least 6 characters"
                                    .tr;
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      GetBuilder<AuthController>(
                        builder: (controller) {
                          final label = controller.isSendingOtp
                              ? "Sending OTP...".tr
                              : "Sign Up".tr;
                          return GestButton(
                            Width: double.infinity,
                            height: 50,
                            buttoncolor: gradient.defoultColor,
                            buttontext: label,
                            onclick: controller.isSendingOtp ? null : _submit,
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyBold,
                              color: WhiteColor,
                              fontSize: 16,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?".tr,
                      style: TextStyle(fontFamily: FontFamily.gilroyMedium),
                    ),
                    TextButton(
                      onPressed: () => Get.to(() => const LoginScreen()),
                      child: Text(
                        "Login".tr,
                        style: TextStyle(
                          fontFamily: FontFamily.gilroyBold,
                          color: gradient.defoultColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        onTap: _onNavTap,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Gilroy Bold',
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Gilroy Medium'),
        selectedItemColor: gradient.defoultColor,
        unselectedItemColor: greytext,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/home-dash.png",
              height: Get.size.height / 35,
              color: _selectedNavIndex == 0 ? gradient.defoultColor : greytext,
            ),
            label: 'Home'.tr,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.theaters,
              size: Get.size.height / 35,
              color: _selectedNavIndex == 1 ? gradient.defoultColor : greytext,
            ),
            label: 'Theatre'.tr,
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/Ticket.png",
              height: Get.size.height / 35,
              color: _selectedNavIndex == 2 ? gradient.defoultColor : greytext,
            ),
            label: 'Tenally'.tr,
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/Profile.png",
              height: Get.size.height / 35,
              color: _selectedNavIndex == 3 ? gradient.defoultColor : greytext,
            ),
            label: 'Profile'.tr,
          ),
        ],
      ),
    );
  }
}
