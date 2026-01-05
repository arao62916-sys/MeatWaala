import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/core/constants/app_constants.dart';
import 'package:meatwaala_app/core/network/base_api_service.dart';
import 'package:meatwaala_app/core/network/network_constents.dart';
import 'package:meatwaala_app/services/storage_service.dart';
import 'package:meatwaala_app/data/models/customer_model.dart';
import 'package:meatwaala_app/data/services/auth_api_service.dart';
import 'package:meatwaala_app/modules/location/controllers/area_controller.dart';
import 'package:meatwaala_app/routes/app_routes.dart';

class AuthController extends GetxController {
  final StorageService _storage = StorageService();
  final AuthApiService _authApiService = AuthApiService();
  final BaseApiService _apiService = BaseApiService();

  // Form Controllers
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final otpController = TextEditingController();
  final forgotPasswordFormKey = GlobalKey<FormState>();
  // Observable States
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final RxString errorMessage = ''.obs;
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;
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

  void _prefillEmailFromSignup() async {
    final tempEmail = _storage.getTempEmail();
    if (tempEmail != null && tempEmail.isNotEmpty) {
      emailController.text = tempEmail;
      log('📧 Pre-filled email from signup: $tempEmail');
    }
  }

  void _loadCurrentUser() async {
    final userId = _storage.getUserId();
    if (userId != null && userId.isNotEmpty) {
      // User is logged in but we don't have full customer data here
      // It will be loaded on login
      log('👤 User ID found: $userId');
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

  void clearFieldError(String key) {
    fieldErrors.remove(key);
  }

  void clearAllFieldErrors() {
    fieldErrors.clear();
  }

  String? getFieldError(String key) {
    return fieldErrors[key];
  }

  void onFieldChanged(String key) {
    clearFieldError(key);
    clearError();
  }

  bool _containsHtmlParagraph(String message) {
    return RegExp(r'<\s*p[^>]*>', caseSensitive: false).hasMatch(message);
  }

  String _stripHtml(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .trim();
  }

  String _mapErrorKeyToField(String key) {
    switch (key.toLowerCase()) {
      case 'email_id':
        return 'email';
      case 'mobile':
        return 'mobile';
      case 'password':
        return 'password';
      case 'name':
        return 'name';
      default:
        return key;
    }
  }

  void _handleApiError(ApiResult result) {
    clearAllFieldErrors();
    clearError();

    final message = result.message.isNotEmpty
        ? result.message
        : 'Something went wrong. Please try again.';

    if (_containsHtmlParagraph(message)) {
      final raw = result.raw;
      final dynamic errorObject =
          raw is Map<String, dynamic> ? raw['aError'] : null;

      if (errorObject is Map) {
        errorObject.forEach((key, value) {
          final fieldKey = _mapErrorKeyToField(key.toString());
          final cleaned = _stripHtml(value?.toString() ?? '');
          if (cleaned.isNotEmpty) {
            fieldErrors[fieldKey] = cleaned;
          }
        });
      }

      if (fieldErrors.isEmpty) {
        final fallback = _stripHtml(message);
        if (fallback.isNotEmpty) {
          _showErrorSnackbar(fallback);
        }
      }
    } else {
      final generalMessage = _stripHtml(message);
      if (generalMessage.isNotEmpty) {
        _showErrorSnackbar(generalMessage);
      }
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Oops!',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
    );
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
    clearAllFieldErrors();
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
        _handleApiError(result);
      }
    } catch (e) {
      log('❌ Signup error: $e');
      _showErrorSnackbar('Signup failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  void _clearSignupForm() {
    nameController.clear();
    phoneController.clear();
    // Don't clear email as it's used for login prefill
    clearAllFieldErrors();
    clearError();
  }

  // ============ LOGIN ============
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;

    clearAllFieldErrors();
    isLoading.value = true;
    clearError();

    try {
      final result = await _authApiService.login(
        emailId: emailController.text.trim(),
        password: passwordController.text,
      );

      if (result.success && result.data != null) {
        final loginData = result.data!;

        // 🚫 Check if customer is active
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

        log('✅ Login successful 🎉');
        log('📩 Message: ${loginData.message}');

        // 💾 Save user data to storage with proper customer information
        // CRITICAL: Ensure all storage operations complete before navigation
        await _storage.saveLoginData(
          token: loginData.customerId, // using customerId as token for auth
          userId: loginData.customerId,
          userName: loginData.customer?.name ?? '',
          userEmail: loginData.customer?.emailId,
          userPhone: loginData.customer?.mobile,
          refreshToken: '', // Add if API provides refresh token
          fullUserData: loginData.customer?.toJson(),
        );

        // Also save/update area if available in customer data
        if (loginData.customer?.areaId != null &&
            loginData.customer!.areaId.isNotEmpty) {
          await _storage.saveSelectedArea(
            areaId: loginData.customer!.areaId,
            areaName: loginData.customer!.areaName,
          );
          log('📍 Area saved: ${loginData.customer!.areaName} (${loginData.customer!.areaId})');
        }

        // CRITICAL: Wait a brief moment to ensure GetStorage writes are flushed
        await Future.delayed(const Duration(milliseconds: 100));

        // 🧾 PRINT STORED DATA WITH EMOJIS
        log('================ 🔐 STORED LOGIN DATA 🔐 ================');
        log('🆔 Customer ID: ${loginData.customerId}');
        log('🔑 Token (customer_id): ${loginData.customerId}');
        log('👤 Customer Name: ${loginData.customer?.name}');
        log('📧 Email: ${loginData.customer?.emailId}');
        log('📱 Mobile: ${loginData.customer?.mobile}');
        log('📍 Area ID: ${loginData.customer?.areaId}');
        log('📍 Area Name: ${loginData.customer?.areaName}');
        log('✅ Status: ${loginData.customer?.status}');
        log('🏠 Address: ${loginData.customer?.address}');
        log('📦 Full Customer Data: ${loginData.customer?.toJson()}');
        log('==========================================================');

        // Verify storage was successful
        final storedToken = _storage.getToken();
        final storedIsLoggedIn = _storage.isLoggedIn();
        log('🔍 Verification after save:');
        log('   - Token stored: ${storedToken != null && storedToken.isNotEmpty}');
        log('   - isLoggedIn flag: $storedIsLoggedIn');

        if (!storedIsLoggedIn || storedToken == null || storedToken.isEmpty) {
          log('❌ CRITICAL: Storage verification failed!');
          _showErrorSnackbar('Failed to save login session. Please try again.');
          return;
        }

        // 🧹 Clear temp email
        await _storage.clearTempEmail();
        log('🗑️ Temporary email cleared');

        // 🔄 Update current customer
        currentCustomer.value = loginData.customer;
        log('🔄 Current customer updated');

        Get.snackbar(
          'Welcome 🎉',
          loginData.message.isNotEmpty
              ? loginData.message
              : 'Logged in successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // 🧽 Clear form
        _clearLoginForm();
        log('🧼 Login form cleared');

        // 🚀 Navigate to home ONLY after all storage operations complete
        log('🏠 Navigating to Main Screen');
        await Future.delayed(
            const Duration(milliseconds: 50)); // Final safety delay
        Get.offAllNamed(AppRoutes.main);
      } else {
        log('❌ Login failed: ${result.message}');
        _handleApiError(result);
      }
    } catch (e) {
      log('🔥 Login error occurred');
      log('❌ Error: $e');
      _showErrorSnackbar('Login failed. Please try again.');
    } finally {
      isLoading.value = false;
      log('⏳ Loading stopped');
    }
  }

  void _clearLoginForm() {
    emailController.clear();
    passwordController.clear();
    clearAllFieldErrors();
    clearError();
  }

// Forgot Password
// ============ FORGOT PASSWORD ============
  Future<void> forgotPassword() async {
    if (forgotPasswordFormKey.currentState != null &&
        !forgotPasswordFormKey.currentState!.validate()) {
      return;
    }

    clearAllFieldErrors();
    isLoading.value = true;
    clearError();

    try {
      log('🔑 Forgot Password request started');

      final result = await _authApiService.forgotPassword(
        emailId: emailController.text.trim(),
        mobile: phoneController.text.trim(),
      );

      if (result.success && result.data != null) {
        final data = result.data!;

        log('✅ Forgot Password Success');
        log('📩 Message: ${data.message}');
        log('👤 Customer ID: ${data.customerId}');
        log('📦 Customer Data: ${data.customer?.toJson()}');

        // Save email for login prefill
        await _storage.saveTempEmail(emailController.text.trim());

        Get.snackbar(
          'Success 🔐',
          data.message.isNotEmpty
              ? data.message
              : 'New password sent to your email',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Clear fields
        phoneController.clear();
        passwordController.clear();
        clearAllFieldErrors();
        clearError();

        // Navigate back to login
        Get.offAllNamed(AppRoutes.login);
      } else {
        log('❌ Forgot Password Failed: ${result.message}');
        _handleApiError(result);
      }
    } catch (e) {
      log('🔥 Forgot Password Error');
      log('❌ Error: $e');

      _showErrorSnackbar('Forgot password failed. Please try again.');
    } finally {
      isLoading.value = false;
      log('⏳ Forgot Password loading stopped');
    }
  }

  // ============ NAVIGATION ============
  void navigateToSignup() {
    Get.toNamed(AppRoutes.signup);
  }

  void navigateToLogin() {
    Get.offAllNamed('login');
  }

  // ============ GETTERS ============
  bool isLoggedIn() {
    return _storage.isLoggedIn();
  }

  String? get currentUserId => _storage.getUserId();
  String? get currentUserName => currentCustomer.value?.name;

  // ============ LOGOUT ============
  /// Logout API - Calls backend and clears local session
  Future<void> logout() async {
    try {
      // Fetch customer ID from storage
      final customerId = _storage.getUserId();

      if (customerId == null || customerId.isEmpty) {
        log('❌ Logout: No customer ID found');
        // Still clear local data and navigate
        await _clearSessionAndNavigate();
        return;
      }

      isLoading.value = true;

      // Build endpoint: login/logout/{customerId}
      final endpoint = '${NetworkConstantsUtil.logout}/$customerId';

      log('🔓 Calling logout API for customer: $customerId');

      // Call logout API
      final result = await _apiService.get<Map<String, dynamic>>(endpoint);

      if (result.success) {
        log('✅ Logout successful: ${result.message}');

        // Clear user session from storage
        await _storage.logout();

        // Show success message
        Get.snackbar(
          'Logged Out',
          result.message.isNotEmpty
              ? result.message
              : 'You have been logged out successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // Navigate to login screen
        Get.offAllNamed(AppRoutes.login);
      } else {
        log('❌ Logout failed: ${result.message}');
        // Even if API fails, clear local session
        await _clearSessionAndNavigate();
      }
    } catch (e) {
      log('❌ Logout error: $e');
      // On error, still clear local session
      await _clearSessionAndNavigate();
    } finally {
      isLoading.value = false;
    }
  }

  /// Helper to clear session and navigate
  Future<void> _clearSessionAndNavigate() async {
    await _storage.logout();
    Get.offAllNamed(AppRoutes.login);
  }
}
