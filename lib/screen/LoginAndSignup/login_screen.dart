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
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = Get.find();
  String _countryCode = "+91";
  int _selectedNavIndex = 0;

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _authController.login(countryCode: _countryCode);
    }
  }

  void _onNavTap(int index) {
    setState(() {
      _selectedNavIndex = index;
    });
    if (index != 3) {
      Get.offAll(() => const BottomBarScreen());
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
                      "Login".tr,
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
                  "Welcome back! Please login".tr,
                  style: TextStyle(
                    fontSize: 16,
                    color: greytext,
                    fontFamily: FontFamily.gilroyMedium,
                  ),
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
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
                      const SizedBox(height: 20),
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
                                onPressed: () {
                                  controller.togglePasswordVisibility();
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your password".tr;
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      GestButton(
                        Width: double.infinity,
                        height: 50,
                        buttoncolor: gradient.defoultColor,
                        buttontext: "Login".tr,
                        onclick: _submit,
                        style: TextStyle(
                          fontFamily: FontFamily.gilroyBold,
                          color: WhiteColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?".tr,
                      style: TextStyle(
                        fontFamily: FontFamily.gilroyMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.to(() => const SignUpScreen()),
                      child: Text(
                        "Sign up".tr,
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
        selectedLabelStyle: const TextStyle(fontFamily: 'Gilroy Bold', fontSize: 12),
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
