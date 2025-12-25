import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/core/services/storage_service.dart';
import 'package:meatwaala_app/data/models/customer_profile_model.dart';
import 'package:meatwaala_app/modules/auth/controllers/auth_controller.dart';
import 'package:meatwaala_app/modules/profile/model/user_model.dart';
import 'package:meatwaala_app/modules/profile/profile_service.dart';
import 'package:meatwaala_app/routes/app_routes.dart';

/// Controller for managing profile-related operations
class ProfileController extends GetxController {
  final ProfileService _profileService = ProfileService();
  
  // ========== Observable States ==========
  final isLoading = false.obs;
  final isUpdating = false.obs;
  final Rx<CustomerProfileModel?> profileData = Rx<CustomerProfileModel?>(null);
  final RxString errorMessage = ''.obs;

  // ========== Form Controllers ==========
  // Profile Form
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final areaIdController = TextEditingController();
  final addressLine1Controller = TextEditingController();
  final addressLine2Controller = TextEditingController();
  final landmarkController = TextEditingController();
  final pincodeController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController();

  // Password Form
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ========== Form Keys ==========
  final updateProfileFormKey = GlobalKey<FormState>();
  final changePasswordFormKey = GlobalKey<FormState>();

  // ========== Password Visibility ==========
  final isOldPasswordVisible = false.obs;
  final isNewPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  // ========== Getters ==========
  String get userName => profileData.value?.name ?? 'User';
  String get userEmail => profileData.value?.emailId ?? 'user@example.com';
  String get userPhone => profileData.value?.mobile ?? '+91 0000000000';
  String get userAddress => profileData.value?.fullAddress ?? 'No address added';
  String get userShortAddress => profileData.value?.shortAddress ?? '';
  String get userInitials => profileData.value?.initials ?? 'U';
  String get profileImage => profileData.value?.profileImage ?? '';
  bool get hasProfile => profileData.value != null;
  bool get isProfileActive => profileData.value?.isActive ?? false;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }

  /// Dispose all text editing controllers
  void _disposeControllers() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    areaIdController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    landmarkController.dispose();
    pincodeController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }

  // ========== FETCH PROFILE ==========
  /// Fetch customer profile from API
  Future<void> fetchProfile() async {
    try {
      final customerId = await StorageService.getUserId();

      if (customerId == null || customerId.isEmpty) {
        errorMessage.value = 'User not logged in';
        log('❌ ProfileController: No customer ID found');
        return;
      }

      isLoading.value = true;
      errorMessage.value = '';

      final profile = await _profileService.fetchProfile(customerId);
      profileData.value = profile;
      _populateFormFields();
      
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      log('❌ ProfileController: $e');
      
      _showErrorSnackbar(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  /// Populate form fields with profile data
  void _populateFormFields() {
    if (profileData.value != null) {
      final profile = profileData.value!;
      nameController.text = profile.name;
      emailController.text = profile.emailId;
      mobileController.text = profile.mobile;
      areaIdController.text = profile.areaId;
      addressLine1Controller.text = profile.addressLine1;
      addressLine2Controller.text = profile.addressLine2;
      landmarkController.text = profile.landmark;
      pincodeController.text = profile.pincode;
      cityController.text = profile.city;
      stateController.text = profile.state;
      countryController.text = profile.country;
    }
  }

  // ========== UPDATE PROFILE ==========
  /// Update customer profile
  Future<void> updateProfile() async {
    if (!updateProfileFormKey.currentState!.validate()) return;

    try {
      final customerId = await StorageService.getUserId();

      if (customerId == null || customerId.isEmpty) {
        log('❌ ProfileController: No customer ID found for update');
        _showErrorSnackbar('User not logged in');
        return;
      }

      isUpdating.value = true;

      final formData = {
        'name': nameController.text.trim(),
        'email_id': emailController.text.trim(),
        'mobile': mobileController.text.trim(),
        'area_id': areaIdController.text.trim(),
        'address_line1': addressLine1Controller.text.trim(),
        'address_line2': addressLine2Controller.text.trim(),
        'landmark': landmarkController.text.trim(),
        'pincode': pincodeController.text.trim(),
        'city': cityController.text.trim(),
        'state': stateController.text.trim(),
        'country': countryController.text.trim(),
      };

      final message = await _profileService.updateProfile(customerId, formData);

      Get.back(); // Close edit screen
      _showSuccessSnackbar(message);
      
      await fetchProfile(); // Refresh profile
      
    } catch (e) {
      log('❌ ProfileController: Update failed: $e');
      _showErrorSnackbar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isUpdating.value = false;
    }
  }

  // ========== CHANGE PASSWORD ==========
  /// Change customer password
  Future<void> changePassword() async {
    if (!changePasswordFormKey.currentState!.validate()) return;

    // Validate password match
    if (newPasswordController.text != confirmPasswordController.text) {
      _showErrorSnackbar('New password and confirm password do not match');
      return;
    }

    try {
      final customerId = await StorageService.getUserId();

      if (customerId == null || customerId.isEmpty) {
        log('❌ ProfileController: No customer ID found for password change');
        _showErrorSnackbar('User not logged in');
        return;
      }

      isUpdating.value = true;

      final passwordData = {
        'password': oldPasswordController.text,
        'new_password': newPasswordController.text,
        'confirm_password': confirmPasswordController.text,
      };

      final message = await _profileService.changePassword(customerId, passwordData);

      Get.back(); // Close change password screen
      _showSuccessSnackbar(message);

      // Clear password fields
      oldPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      
    } catch (e) {
      log('❌ ProfileController: Password change failed: $e');
      _showErrorSnackbar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isUpdating.value = false;
    }
  }

  // ========== VALIDATORS ==========
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (value.trim().length < 10) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateAreaId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Area is required';
    }
    return null;
  }

  String? validatePincode(String? value) {
    if (value != null && value.isNotEmpty) {
      if (value.length != 6) {
        return 'Enter a valid 6-digit pincode';
      }
    }
    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }
    return null;
  }

  // ========== PASSWORD VISIBILITY TOGGLES ==========
  void toggleOldPasswordVisibility() {
    isOldPasswordVisible.value = !isOldPasswordVisible.value;
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordVisible.value = !isNewPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  // ========== NAVIGATION ==========
  void navigateToEditProfile() {
    Get.toNamed(AppRoutes.editProfile);
  }

  void navigateToChangePassword() {
    Get.toNamed(AppRoutes.changePassword);
  }

  void navigateToOrders() {
    Get.toNamed(AppRoutes.orderHistory);
  }

  void navigateToAboutUs() {
    Get.toNamed(AppRoutes.aboutUs);
  }

  void navigateToContactUs() {
    Get.toNamed(AppRoutes.contactUs);
  }

  void navigateToPrivacyPolicy() {
    Get.toNamed(AppRoutes.privacyPolicy);
  }

  void navigateToTerms() {
    Get.toNamed(AppRoutes.terms);
  }

  // ========== LOGOUT ==========
  /// Show logout confirmation dialog
  void logout() {
    Get.defaultDialog(
      title: 'Logout',
      titleStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      middleText: 'Are you sure you want to logout?',
      textConfirm: 'Yes, Logout',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.red,
      buttonColor: Colors.red,
      radius: 12,
      onConfirm: () async {
        Get.back();
        final authController = Get.find<AuthController>();
        await authController.logout();
      },
    );
  }

  // ========== HELPER METHODS ==========
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade400,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade400,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }
}