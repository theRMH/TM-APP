// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings, unused_local_variable

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../Api/config.dart';
import '../Api/data_store.dart';
import '../firebase/auth_firebase.dart';
import '../helpar/routes_const.dart';
import '../screen/bottombar_screen.dart';
import '../utils/Custom_widget.dart';

/// Manages the simplified login/signup flow used by the new themed screens.
class AuthController extends GetxController {
  final FirebaseAuthService firebaseAuthService = Get.put(
    FirebaseAuthService(),
  );

  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController number = TextEditingController();
  final TextEditingController password = TextEditingController();

  bool showPassword = true;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final TextEditingController otpController = TextEditingController();

  bool isOtpProcessing = false;
  bool isOtpResending = false;
  int resendCooldownSeconds = 0;
  Timer? _resendCooldownTimer;
  String _verificationId = '';
  int? _forceResendingToken;
  String _pendingCountryCode = '';
  String _pendingPhoneNumber = '';
  bool _isSignUpPending = false;
  bool _isOtpDialogOpen = false;
  bool isSendingOtp = false;

  void togglePasswordVisibility() {
    showPassword = !showPassword;
    update();
  }

  String get otpDisplayPhone => _pendingPhoneNumber.isNotEmpty
      ? '$_pendingCountryCode $_pendingPhoneNumber'
      : '';

  /// E.164 format required by Firebase: +[countryCode][number] (no spaces).
  String get _fullPhoneNumber {
    final code = _pendingCountryCode.trim();
    final num = _pendingPhoneNumber.trim().replaceAll(RegExp(r'\s'), '');
    final prefix = code.startsWith('+') ? code : '+$code';
    return '$prefix$num';
  }

  Future<void> startPhoneAuthentication({
    required String countryCode,
    required bool isSignUp,
  }) async {
    if (isSendingOtp) {
      showToastMessage("Please wait...".tr);
      return;
    }
    final trimmedNumber = number.text.trim();
    if (trimmedNumber.isEmpty) {
      showToastMessage("Please enter your phone number".tr);
      return;
    }
    _pendingPhoneNumber = trimmedNumber;
    _pendingCountryCode = countryCode;
    _isSignUpPending = isSignUp;
    _verificationId = '';
    if (!_isOtpDialogOpen) {
      _openOtpScreen();
    }
    isSendingOtp = true;
    update();
    try {
      await _startPhoneVerification();
    } finally {
      isSendingOtp = false;
      update();
    }
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

  Future<void> _startPhoneVerification({bool forceResend = false}) async {
    final phone = _fullPhoneNumber;
    if (phone.isEmpty) {
      showToastMessage("Unable to verify phone number".tr);
      return;
    }
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (credential) =>
            _handlePhoneCredential(credential),
        verificationFailed: (exception) {
          _closeOtpScreen();
          showToastMessage(exception.message ?? "Phone verification failed".tr);
        },
        codeSent: (verificationId, forceResendingToken) {
          _verificationId = verificationId;
          _forceResendingToken = forceResendingToken;
          _startResendCooldown();
          showToastMessage("OTP sent to $phone");
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
        forceResendingToken: forceResend ? _forceResendingToken : null,
      );
    } on FirebaseAuthException catch (e) {
      _closeOtpScreen();
      showToastMessage(e.message ?? "Failed to send OTP".tr);
    } catch (e) {
      _closeOtpScreen();
      showToastMessage("Unable to verify phone number".tr);
    }
  }

  void _startResendCooldown() {
    resendCooldownSeconds = 30;
    _resendCooldownTimer?.cancel();
    _resendCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCooldownSeconds <= 0) {
        resendCooldownSeconds = 0;
        timer.cancel();
      } else {
        resendCooldownSeconds--;
      }
      update();
    });
    update();
  }

  void _openOtpScreen() {
    if (_isOtpDialogOpen || Get.context == null) return;
    _isOtpDialogOpen = true;
    otpController.clear();
    Get.toNamed(Routes.otpVerificationScreen)?.then((_) {
      _isOtpDialogOpen = false;
    });
  }

  void _closeOtpScreen() {
    if (!_isOtpDialogOpen) return;
    try {
      Get.back();
    } catch (_) {}
  }

  Future<void> verifyOtp() async {
    if (_verificationId.isEmpty) {
      showToastMessage("Unable to verify OTP".tr);
      return;
    }
    final code = otpController.text.trim();
    if (code.length < 6) {
      showToastMessage("Please enter the 6-digit code".tr);
      return;
    }
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: code,
    );
    await _handlePhoneCredential(credential);
  }

  Future<void> _handlePhoneCredential(PhoneAuthCredential credential) async {
    try {
      isOtpProcessing = true;
      update();
      await _firebaseAuth.signInWithCredential(credential);
                            _closeOtpScreen();
      if (_pendingCountryCode.isNotEmpty) {
        if (_isSignUpPending) {
          await signUp(countryCode: _pendingCountryCode);
        } else {
          await login(countryCode: _pendingCountryCode);
        }
      }
      _resetOtpState();
    } on FirebaseAuthException catch (e) {
      showToastMessage(e.message ?? "OTP verification failed".tr);
    } finally {
      isOtpProcessing = false;
      update();
    }
  }

  Future<void> resendOtp() async {
    if (resendCooldownSeconds > 0) return;
    isOtpResending = true;
    update();
    try {
      await _startPhoneVerification(forceResend: true);
    } finally {
      isOtpResending = false;
      update();
    }
  }

  void _resetOtpState() {
    _resendCooldownTimer?.cancel();
    _resendCooldownTimer = null;
    resendCooldownSeconds = 0;
    _verificationId = '';
    _forceResendingToken = null;
    _pendingCountryCode = '';
    _pendingPhoneNumber = '';
    _isSignUpPending = false;
    otpController.clear();
    _isOtpDialogOpen = false;
  }

  @override
  void onClose() {
    name.dispose();
    email.dispose();
    number.dispose();
    password.dispose();
    otpController.dispose();
    _resendCooldownTimer?.cancel();
    super.onClose();
  }
}
