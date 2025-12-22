import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/modules/navigation/controllers/bottom_nav_controller.dart';
import 'package:meatwaala_app/modules/navigation/widgets/custom_bottom_nav_bar.dart';
import 'package:meatwaala_app/modules/home/views/home_view.dart';
import 'package:meatwaala_app/modules/categories/views/categories_view.dart';
import 'package:meatwaala_app/modules/orders/views/order_history_view.dart';
import 'package:meatwaala_app/modules/profile/views/profile_view.dart';

import 'package:meatwaala_app/core/widgets/drawer/app_drawer.dart';

class MainScreen extends GetView<BottomNavController> {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // List of screens for each tab
    final List<Widget> screens = [
      const HomeView(),
      const CategoriesView(),
      const OrderHistoryView(),
      const ProfileView(),
    ];

    return Scaffold(
      key: controller.scaffoldKey,
      drawer: const AppDrawer(),

      /// Body with PageView for smooth transitions
      body: PageView(
        controller: controller.pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe
        onPageChanged: controller.onPageChanged,
        children: screens,
      ),

      /// Extended body to allow content behind the notch
      extendBody: true,

      /// Animated Bottom Navigation Bar
      bottomNavigationBar: Obx(
        () => CustomBottomNavBar(
          controller: controller.notchBottomBarController,
          selectedIndex: controller.selectedIndex.value,
          onTap: controller.changeTab,
        ),
      ),
    );
  }
}
