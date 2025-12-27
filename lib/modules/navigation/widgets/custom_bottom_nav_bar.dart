import 'package:flutter/material.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:meatwaala_app/core/theme/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final NotchBottomBarController controller;
  final ValueChanged<int> onTap;
  final int selectedIndex;

  const CustomBottomNavBar({
    super.key,
    required this.controller,
    required this.onTap,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedNotchBottomBar(
      /// Controller for the bottom bar
      notchBottomBarController: controller,

      /// Color of the bottom bar
      color: Colors.white,

      /// Show shadow above the bottom bar
      showShadow: true,

      /// Shadow elevation
      shadowElevation: 8,

      /// Elevation of the bottom bar
      elevation: 8,

      /// Bottom padding for safe area
      bottomBarHeight: 65,

      /// Notch color (center elevated part)
      notchColor: AppColors.primary,

      /// Show label or not
      showLabel: true,

      /// Show blur effect
      showBlurBottomBar: false,

      /// Blur filter intensity
      blurOpacity: 0.0,

      /// Blur filter color
      blurFilterX: 5.0,
      blurFilterY: 5.0,

      /// Animation duration
      durationInMilliSeconds: 300,

      /// Item label style
      itemLabelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),

      /// Notch shape
      notchShader: const SweepGradient(
        startAngle: 0,
        endAngle: 3.14 * 2,
        colors: [
          AppColors.primary,
          AppColors.secondary,
          AppColors.primary,
        ],
        tileMode: TileMode.mirror,
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 8.0)),

      /// Remove margin
      removeMargins: false,

      /// Bottom bar items
      bottomBarItems: const [
        /// Home
        BottomBarItem(
          inActiveItem: Icon(
            Icons.home_outlined,
            color: AppColors.textSecondary,
          ),
          activeItem: Icon(
            Icons.home,
            color: Colors.white,
          ),
          itemLabel: 'Home',
        ),

        /// Categories
        BottomBarItem(
          inActiveItem: Icon(
            Icons.category_outlined,
            color: AppColors.textSecondary,
          ),
          activeItem: Icon(
            Icons.category,
            color: Colors.white,
          ),
          itemLabel: 'Categories',
        ),

        /// Orders
        BottomBarItem(
          inActiveItem: Icon(
            Icons.receipt_long_outlined,
            color: AppColors.textSecondary,
          ),
          activeItem: Icon(
            Icons.receipt_long,
            color: Colors.white,
          ),
          itemLabel: 'Orders',
        ),

        /// Profile
        BottomBarItem(
          inActiveItem: Icon(
            Icons.person_outline,
            color: AppColors.textSecondary,
          ),
          activeItem: Icon(
            Icons.person,
            color: Colors.white,
          ),
          itemLabel: 'Profile',
        ),
      ],

      /// On tap callback
      onTap: onTap,

      /// Knotch gradient
      kIconSize: 24.0,
      kBottomRadius: 28.0,
    );
  }
}
