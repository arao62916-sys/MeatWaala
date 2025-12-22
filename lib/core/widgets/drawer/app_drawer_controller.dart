import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/data/models/user_model.dart';

/// Controller for managing drawer state and user data
class AppDrawerController extends GetxController {
  // Observable user data
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  // Current route for highlighting active menu item
  final RxString currentRoute = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _trackCurrentRoute();
  }

  /// Load user data from storage or API
  void _loadUserData() {
    // TODO: Load from GetStorage or API
    // For now, using mock data
    currentUser.value = UserModel(
      id: '1',
      name: 'John Doe',
      email: 'john.doe@example.com',
      phone: '+91 98765 43210',
      profileImage: null, // Can be a URL
      createdAt: DateTime.now(),
    );
  }

  /// Track current route for highlighting active menu
  /// Track current route for highlighting active menu
  void _trackCurrentRoute() {
    // Set initial route
    currentRoute.value = Get.currentRoute;
  }

  /// Update user profile image
  void updateProfileImage(String imageUrl) {
    if (currentUser.value != null) {
      currentUser.value = currentUser.value!.copyWith(profileImage: imageUrl);
    }
  }

  /// Logout with confirmation
  Future<void> logout() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Clear user data from storage
      currentUser.value = null;
      // Navigate to login
      Get.offAllNamed('/login');
    }
  }

  /// Navigate to profile screen
  void navigateToProfile() {
    Get.back(); // Close drawer
    Get.toNamed('/profile');
  }
}
