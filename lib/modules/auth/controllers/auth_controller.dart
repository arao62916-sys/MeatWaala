import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/core/constants/app_constants.dart';
import 'package:meatwaala_app/data/models/customer_model.dart';
import 'package:meatwaala_app/data/services/auth_api_service.dart';
import 'package:meatwaala_app/modules/location/controllers/area_controller.dart';
import 'package:meatwaala_app/routes/app_routes.dart';
import 'package:meatwaala_app/services/storage_service.dart';

class AuthController extends GetxController {
  final StorageService _storage = StorageService();
  final AuthApiService _authApiService = AuthApiService();

  // Form Controllers
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final otpController = TextEditingController();

  // Observable States
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final RxString errorMessage = ''.obs;
  // Track login method: true for phone, false for email
  final RxBool isPhoneLogin = true.obs;

  // Current logged in customer
  final Rx<CustomerModel?> currentCustomer = Rx<CustomerModel?>(null);

  // Form Keys
  final loginFormKey = GlobalKey<FormState>();
  final signupFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    // Pre-fill email if coming from signup
    _prefillEmailFromSignup();
    // Load current user data if exists
    _loadCurrentUser();
  }

  void _prefillEmailFromSignup() {
    final tempEmail = _storage.getTempEmail();
    if (tempEmail != null && tempEmail.isNotEmpty) {
      emailController.text = tempEmail;
      log('📧 Pre-filled email from signup: $tempEmail');
    }
  }

  void _loadCurrentUser() {
    final userData = _storage.getUserData();
    if (userData != null) {
      currentCustomer.value = CustomerModel.fromJson(userData);
      log('👤 Loaded current user: ${currentCustomer.value?.name}');
    }
  }

  // Do not dispose controllers in onClose to avoid 'used after being disposed' errors
  // GetX will handle disposal when the controller is truly removed from memory

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  // Clear error message
  void clearError() {
    errorMessage.value = '';
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
    if (value.length < 10) {
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

  // ============ SIGNUP ============
  Future<void> signup() async {
    if (!signupFormKey.currentState!.validate()) return;

    // Get selected area from AreaController
    final areaController = Get.find<AreaController>();
    if (!areaController.hasSelectedArea) {
      Get.snackbar(
        'Error',
        'Please select your delivery area',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    clearError();

    try {
      final result = await _authApiService.signup(
        name: nameController.text.trim(),
        emailId: emailController.text.trim(),
        mobile: phoneController.text.trim(),
        areaId: areaController.selectedAreaId!,
      );

      if (result.success && result.data != null) {
        log('✅ Signup successful: ${result.message}');

        // Save email temporarily for login prefill
        await _storage.saveTempEmail(emailController.text.trim());

        // Confirm area selection
        await areaController.confirmSelection();

        Get.snackbar(
          'Success',
          result.data!.message.isNotEmpty
              ? result.data!.message
              : 'Password sent to your email',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Clear form
        _clearSignupForm();

        // Navigate to login
        Get.offAllNamed(AppRoutes.login);
      } else {
        errorMessage.value = result.message;
        Get.snackbar(
          'Signup Failed',
          result.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      log('❌ Signup error: $e');
      errorMessage.value = 'Signup failed. Please try again.';
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _clearSignupForm() {
    nameController.clear();
    phoneController.clear();
    // Don't clear email as it's used for login prefill
  }

  // ============ LOGIN ============
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;

    isLoading.value = true;
    clearError();

    try {
      final result = await _authApiService.login(
        emailId: emailController.text.trim(),
        password: passwordController.text,
      );

      if (result.success && result.data != null) {
        final loginData = result.data!;

        // Check if customer is active
        if (loginData.customer != null && !loginData.customer!.isActive) {
          errorMessage.value =
              'Your account is disabled. Please contact support.';
          Get.snackbar(
            'Account Disabled',
            'Your account is disabled. Please contact support.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          isLoading.value = false;
          return;
        }

        log('✅ Login successful: ${loginData.message}');

        // Save user data to storage
        await _storage.saveUserData(
          token: loginData
              .customerId, // Using customerId as token if no separate token
          customerId: loginData.customerId,
          customerData: loginData.customer?.toJson() ?? {},
        );

        // Clear temp email
        await _storage.clearTempEmail();

        // Update current customer
        currentCustomer.value = loginData.customer;

        Get.snackbar(
          'Welcome!',
          loginData.message.isNotEmpty
              ? loginData.message
              : 'Logged in successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Clear form
        _clearLoginForm();

        // Navigate to home
        Get.offAllNamed(AppRoutes.main);
      } else {
        errorMessage.value = result.message;
        Get.snackbar(
          'Login Failed',
          result.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      log('❌ Login error: $e');
      errorMessage.value = 'Login failed. Please try again.';
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _clearLoginForm() {
    emailController.clear();
    passwordController.clear();
  }

  // ============ LOGOUT ============
  Future<void> logout() async {
    isLoading.value = true;

    try {
      // Call logout API
      await _authApiService.logout();
    } catch (e) {
      log('❌ Logout API error (continuing with local logout): $e');
    }

    // Clear local data regardless of API result
    await _storage.clearUserData();
    currentCustomer.value = null;

    isLoading.value = false;

    Get.snackbar(
      'Logged Out',
      'You have been logged out successfully',
      snackPosition: SnackPosition.BOTTOM,
    );

    // Navigate to login
    Get.offAllNamed(AppRoutes.login);
  }

  // ============ NAVIGATION ============
  void navigateToSignup() {
    Get.toNamed(AppRoutes.signup);
  }

  void navigateToLogin() {
    Get.back();
  }

  // ============ OTP VERIFICATION ============
  Future<void> verifyOtp() async {
    isLoading.value = true;
    clearError();
    try {
      final otp = otpController.text.trim();
      if (otp.length != AppConstants.otpLength) {
        Get.snackbar(
          'Invalid OTP',
          'Please enter a valid ${AppConstants.otpLength}-digit OTP.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }
      // TODO: Implement actual OTP verification logic with API
      // Example success:
      Get.snackbar(
        'Success',
        'OTP verified successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      // Navigate to home or next screen
      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to verify OTP. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============ GETTERS ============
  bool get isLoggedIn => _storage.isLoggedIn();
  String? get currentUserId => _storage.getUserId();
  String? get currentUserName => currentCustomer.value?.name;
}
