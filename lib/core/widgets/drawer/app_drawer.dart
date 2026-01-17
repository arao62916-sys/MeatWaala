import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:meatwaala_app/core/theme/app_colors.dart';
import 'package:meatwaala_app/routes/app_routes.dart';
import 'package:meatwaala_app/core/widgets/drawer/app_drawer_controller.dart';
import 'package:meatwaala_app/core/widgets/drawer/drawer_menu_item.dart';
import 'package:meatwaala_app/modules/navigation/controllers/bottom_nav_controller.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  /// Bottom bar tab route → index mapping
  static const Map<String, int> _bottomTabRoutes = {
    AppRoutes.home: 0,
    AppRoutes.categories: 1,
    AppRoutes.orders: 2,
    AppRoutes.orderHistory: 2,
    AppRoutes.profile: 3,
  };

  @override
  Widget build(BuildContext context) {
    final drawerController = Get.put(AppDrawerController());
    final bottomNavController = Get.find<BottomNavController>();

    /// Sync drawer when bottom tab changes
    ever(bottomNavController.selectedIndex, (int index) {
      final match = _bottomTabRoutes.entries
          .firstWhere(
            (e) => e.value == index,
            orElse: () => const MapEntry('', -1),
          );

      if (match != null) {
        drawerController.currentRoute.value = match.key;
      }
    });

    /// Sync drawer on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      drawerController.currentRoute.value = Get.currentRoute;
    });

    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    // Group 1: Main Navigation
    final List<DrawerMenuItem> mainMenuItems = [
      DrawerMenuItem(
        title: 'Home',
        icon: Icons.home_outlined,
        route: AppRoutes.home,
        onTap: () => _navigate(AppRoutes.home),
      ),
      DrawerMenuItem(
        title: 'Categories',
        icon: Icons.category_outlined,
        route: AppRoutes.categories,
        onTap: () => _navigate(AppRoutes.categories),
      ),
      DrawerMenuItem(
        title: 'My Orders',
        icon: Icons.receipt_long_outlined,
        route: AppRoutes.orders,
        onTap: () => _navigate(AppRoutes.orders),
      ),
    ];

    // Group 2: Shopping
    final List<DrawerMenuItem> shoppingItems = [
      DrawerMenuItem(
        title: 'Cart',
        icon: Icons.shopping_cart_outlined,
        route: AppRoutes.cart,
        showBadge: true,
        badgeCount: 2,
        onTap: () => _navigate(AppRoutes.cart),
      ),
      DrawerMenuItem(
        title: 'Offers',
        icon: Icons.local_offer_outlined,
        route: '/offers',
        onTap: () => _navigate('/offers'),
      ),
    ];

    // Group 3: Account & Settings
    final List<DrawerMenuItem> accountItems = [
      // DrawerMenuItem(
      //   title: 'Addresses',
      //   icon: Icons.location_on_outlined,
      //   route: '/addresses',
      //   onTap: () => _navigate('/addresses'),
      // ),
      // const DrawerMenuItem(
      //   title: 'Notifications',
      //   icon: Icons.notifications_outlined,
      //   route: '/notifications',
      // ),
    ];

    // Group 4: Help & Info
    final List<DrawerMenuItem> helpItems = [
      const DrawerMenuItem(
        title: 'Help & Support',
        icon: Icons.support_agent,
        route: '/support',
      ),
      DrawerMenuItem(
        title: 'About Us',
        icon: Icons.info_outline,
        route: AppRoutes.aboutUs,
        onTap: () => _navigate(AppRoutes.aboutUs),
      ),
        DrawerMenuItem(
        title: 'Contact Us',
        icon: Icons.info_outline,
        route: AppRoutes.contactUs,
        onTap: () => _navigate(AppRoutes.contactUs),
      ),
    ];

    return Drawer(
      elevation: 0,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context, drawerController),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 16, left: 12, right: 12),
              children: [
                // Main Navigation
                ...mainMenuItems.map((item) => 
                  _buildMenuItem(context, item, drawerController)),
                
                // _buildDivider(),
                
                // Shopping
                ...shoppingItems.map((item) => 
                  _buildMenuItem(context, item, drawerController)),
                
                // _buildDivider(),
                
                // Account & Settings
                ...accountItems.map((item) => 
                  _buildMenuItem(context, item, drawerController)),
                
                // _buildDivider(),
                
                // Help & Info
                ...helpItems.map((item) => 
                  _buildMenuItem(context, item, drawerController)),
              ],
            ),
          ),
          _buildFooter(context, drawerController, bottomPadding),
        ],
      ),
    );
  }

  /// ✅ Drawer → Bottom bar + page sync
  void _navigate(String route) {
    Get.back(); // close drawer

    // Bottom bar routes → change index ONLY
    if (_bottomTabRoutes.containsKey(route)) {
      final bottomNavController = Get.find<BottomNavController>();
      final drawerController = Get.find<AppDrawerController>();

      final int index = _bottomTabRoutes[route]!;

      bottomNavController.changeTab(index);
      drawerController.currentRoute.value = route;

      return;
    }

    // Normal routes
    if (Get.currentRoute != route) {
      Get.toNamed(route);
    }
  }

  /// Divider between menu groups
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Divider(
        color: AppColors.textHint.withOpacity(0.2),
        thickness: 1,
      ),
    );
  }

  /// Header
  Widget _buildHeader(
      BuildContext context, AppDrawerController controller) {
    return GestureDetector(
      onTap: controller.navigateToProfile,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 24,
          bottom: 24,
          left: 24,
          right: 24,
        ),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(topRight: Radius.circular(28)),
          gradient: LinearGradient(
            colors: [
              UserColors.headerBgStart,
              UserColors.headerBgEnd,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Obx(() {
          final user = controller.currentUser.value;
          return Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                backgroundImage: user?.profileImage != null
                    ? CachedNetworkImageProvider(user!.profileImage!)
                    : null,
                child: user?.profileImage == null
                    ? const Icon(Icons.person,
                        size: 32, color: AppColors.primary)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Guest User',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? user?.phone ?? 'Sign In',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  /// Menu item with simple line separator
  Widget _buildMenuItem(BuildContext context, DrawerMenuItem item,
      AppDrawerController controller) {
    return Obx(() {
      final bool isActive = controller.currentRoute.value == item.route;

      return Column(
        children: [
          InkWell(
            onTap: item.onTap ?? () => _navigate(item.route),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary.withOpacity(0.1) : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    color:
                        isActive ? AppColors.primary : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      item.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.w500,
                          ),
                    ),
                  ),
                  // if (item.showBadge && (item.badgeCount ?? 0) > 0)
                  //   Container(
                  //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  //     decoration: BoxDecoration(
                  //       color: AppColors.primary,
                  //       borderRadius: BorderRadius.circular(10),
                  //     ),
                  //     child: Text(
                  //       '${item.badgeCount ?? 0}',
                  //       style: const TextStyle(
                  //         color: Colors.white,
                  //         fontSize: 12,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //   ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Divider(
              color: AppColors.textHint.withOpacity(0.2),
              thickness: 1,
              height: 1,
            ),
          ),
        ],
      );
    });
  }

  /// Footer
  Widget _buildFooter(BuildContext context, AppDrawerController controller,
      double bottomPadding) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: 24 + bottomPadding,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.textHint.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          InkWell(
            onTap: controller.logout,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: const [
                  Icon(Icons.logout, color: AppColors.error),
                  SizedBox(width: 16),
                  Text(
                    'Logout',
                    style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                        fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'App Version 1.0.0',
            style: TextStyle(
              color: AppColors.textHint,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class UserColors {
  static const Color headerBgStart = Color(0xFFD32F2F);
  static const Color headerBgEnd = Color(0xFFB71C1C);
}