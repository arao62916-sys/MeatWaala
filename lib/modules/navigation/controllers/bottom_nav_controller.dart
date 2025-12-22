import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';

class BottomNavController extends GetxController {
  // Reactive selected tab index
  final RxInt selectedIndex = 0.obs;

  // Controllers for AnimatedNotchBottomBar
  late NotchBottomBarController notchBottomBarController;
  late PageController pageController;

  // Maximum number of pages
  final int maxCount = 4;

  // Scaffold key to control drawer from other pages
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  void closeDrawer() {
    scaffoldKey.currentState?.closeDrawer();
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize controllers
    pageController = PageController(initialPage: 0);
    notchBottomBarController = NotchBottomBarController(index: 0);
    selectedIndex.value = 0;
  }

  @override
  void onClose() {
    // Dispose controllers
    pageController.dispose();
    notchBottomBarController.dispose();
    super.onClose();
  }

  // Change tab method
  void changeTab(int index) {
    selectedIndex.value = index;
    pageController.jumpToPage(index);
  }

  // Handle page change from PageView
  void onPageChanged(int index) {
    selectedIndex.value = index;
  }
}
