import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/core/constants/app_constants.dart';
import 'package:meatwaala_app/routes/app_routes.dart';
import 'package:meatwaala_app/services/storage_service.dart';

class AuthController extends GetxController {
  final StorageService _storage = StorageService();

  // Form Controllers
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final otpController = TextEditingController();

  // Observable States
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final isPhoneLogin = true.obs; // true for phone, false for email

  // Form Keys
  final loginFormKey = GlobalKey<FormState>();
  final signupFormKey = GlobalKey<FormState>();

  @override
  void onClose() {
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    nameController.dispose();
    otpController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleLoginMethod() {
    isPhoneLogin.value = !isPhoneLogin.value;
  }

  // Validators
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!GetUtils.isPhoneNumber(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  // Login
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;

    isLoading.value = true;

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Mock login - save token
    _storage.write(AppConstants.storageKeyToken, 'mock_token_12345');
    _storage.write(AppConstants.storageKeyUserId, 'user_001');

    isLoading.value = false;

    // Navigate to location selection or home
    final hasCity = _storage.read(AppConstants.storageKeySelectedCity);
    if (hasCity == null) {
      Get.offAllNamed(AppRoutes.location);
    } else {
      Get.offAllNamed(AppRoutes.home);
    }

    Get.snackbar(
      'Success',
      'Logged in successfully!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Signup
  Future<void> signup() async {
    if (!signupFormKey.currentState!.validate()) return;

    isLoading.value = true;

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    isLoading.value = false;

    // Navigate to OTP screen
    Get.toNamed(AppRoutes.otp);

    Get.snackbar(
      'OTP Sent',
      'Please check your ${isPhoneLogin.value ? 'phone' : 'email'} for OTP',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Verify OTP
  Future<void> verifyOtp() async {
    if (otpController.text.length != AppConstants.otpLength) {
      Get.snackbar(
        'Error',
        'Please enter valid OTP',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Mock verification - save token
    _storage.write(AppConstants.storageKeyToken, 'mock_token_12345');
    _storage.write(AppConstants.storageKeyUserId, 'user_001');

    isLoading.value = false;

    // Navigate to location selection
    Get.offAllNamed(AppRoutes.location);

    Get.snackbar(
      'Success',
      'Account created successfully!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void navigateToSignup() {
    Get.toNamed(AppRoutes.signup);
  }

  void navigateToLogin() {
    Get.back();
  }
}
