import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/modules/navigation/controllers/bottom_nav_controller.dart';
import 'package:meatwaala_app/modules/home/views/home_view.dart';
import 'package:meatwaala_app/modules/categories/views/categories_view.dart';
import 'package:meatwaala_app/modules/orders/views/order_history_view.dart';
import 'package:meatwaala_app/modules/profile/views/profile_view.dart';

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
      body: Obx(() => IndexedStack(
            index: controller.selectedIndex.value,
            children: screens,
          )),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.selectedIndex.value,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category_outlined),
              activeIcon: Icon(Icons.category),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
