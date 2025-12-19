import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/core/constants/app_constants.dart';
import 'package:meatwaala_app/routes/app_routes.dart';
import 'package:meatwaala_app/services/storage_service.dart';

class ProfileController extends GetxController {
  final StorageService _storage = StorageService();

  final userName = 'John Doe'.obs;
  final userEmail = 'john.doe@example.com'.obs;
  final userPhone = '+91 9876543210'.obs;

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

  void logout() {
    Get.defaultDialog(
      title: 'Logout',
      middleText: 'Are you sure you want to logout?',
      textConfirm: 'Yes',
      textCancel: 'No',
      confirmTextColor: const Color(0xFFFFFFFF),
      onConfirm: () {
        _storage.remove(AppConstants.storageKeyToken);
        _storage.remove(AppConstants.storageKeyUserId);
        Get.back(); // Close dialog
        Get.offAllNamed(AppRoutes.login);
      },
    );
  }
}
