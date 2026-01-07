import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/modules/navigation/controllers/bottom_nav_controller.dart';
import 'package:meatwaala_app/modules/navigation/widgets/custom_bottom_nav_bar.dart';
import 'package:meatwaala_app/modules/home/views/home_view.dart';
import 'package:meatwaala_app/modules/categories/views/categories_view.dart';
import 'package:meatwaala_app/modules/orders/views/order_history_view.dart';
import 'package:meatwaala_app/modules/orders/views/order_list_view.dart';
import 'package:meatwaala_app/modules/profile/views/profile_view.dart';

import 'package:meatwaala_app/core/widgets/drawer/app_drawer.dart';

class MainScreen extends GetView<BottomNavController> {
  const MainScreen({super.key});

  static final List<Widget> _screens = [
    HomeView(),
    CategoriesView(),
    OrderListView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      drawer: const AppDrawer(),
      extendBody: true,

      body: PageView(
        controller: controller.pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: controller.onPageChanged,
        children: _screens,
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: CustomBottomNavBar(
          controller: controller.notchBottomBarController,
          onTap: controller.changeTab,
          selectedIndex: controller.selectedIndex.value,
        ),
      ),
    );
  }
}
