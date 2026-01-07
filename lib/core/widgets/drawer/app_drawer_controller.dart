import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/data/models/user_model.dart';
import 'package:meatwaala_app/modules/auth/controllers/auth_controller.dart';
import 'package:meatwaala_app/services/storage_service.dart';
import 'package:meatwaala_app/modules/navigation/controllers/bottom_nav_controller.dart';

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
    final storage = StorageService();

    // Load user data from storage
    final userId = storage.getUserId();
    final userName = storage.getUserName();
    final userEmail = storage.getUserEmail();
    final userPhone = storage.getUserPhone();

    // Only set user if logged in
    if (userId != null && userId.isNotEmpty) {
      currentUser.value = UserModel(
        id: userId,
        name: userName ?? 'User',
        email: userEmail ?? '',
        phone: userPhone ?? '',
        profileImage: null, // Can be loaded from profile API
        createdAt: DateTime.now(),
      );
    } else {
      currentUser.value = null;
    }
  }

  /// Refresh user data (call after profile updates)
  void refreshUserData() {
    _loadUserData();
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
      // Call AuthController's logout method
      try {
        final authController = Get.find<AuthController>();
        await authController.logout();
      } catch (e) {
        // If AuthController not found, handle logout manually
        print('⚠️ AuthController not found, clearing session manually');
        final storage = StorageService();
        await storage.logout();
        currentUser.value = null;
        Get.offAllNamed('/login');
      }
    }
  }

  /// Navigate to profile screen
  void navigateToProfile() {
    Get.back(); // Close drawer

    // Check if we're already on MainScreen
    if (Get.currentRoute == '/main') {
      // Just switch to profile tab (index 3)
      try {
        final navController = Get.find<BottomNavController>();
        navController.changeTab(3);
      } catch (e) {
        // If controller not found, navigate to main
        Get.offAllNamed('/main');
      }
    } else {
      // Navigate to MainScreen and switch to profile tab
      Get.offAllNamed('/main');
      // Wait for navigation to complete, then switch tab
      Future.delayed(const Duration(milliseconds: 100), () {
        try {
          final navController = Get.find<BottomNavController>();
          navController.changeTab(3);
        } catch (e) {
          // Controller not ready yet, ignore
        }
      });
    }
  }
}
