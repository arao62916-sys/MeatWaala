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

    final List<DrawerMenuItem> menuItems = [
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
      DrawerMenuItem(
        title: 'Cart',
        icon: Icons.shopping_cart_outlined,
        route: AppRoutes.cart,
        showBadge: true,
        badgeCount: 2,
        onTap: () => _navigate(AppRoutes.cart),
      ),
      DrawerMenuItem(
        title: 'Addresses',
        icon: Icons.location_on_outlined,
        route: '/addresses',
        onTap: () => _navigate('/addresses'),
      ),
      DrawerMenuItem(
        title: 'Offers',
        icon: Icons.local_offer_outlined,
        route: '/offers',
        onTap: () => _navigate('/offers'),
      ),
      const DrawerMenuItem(
        title: 'Notifications',
        icon: Icons.notifications_outlined,
        route: '/notifications',
      ),
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
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 16, left: 12, right: 12),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                return _buildMenuItem(
                    context, menuItems[index], drawerController);
              },
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

  /// Menu item
  Widget _buildMenuItem(BuildContext context, DrawerMenuItem item,
      AppDrawerController controller) {
    return Obx(() {
      final bool isActive = controller.currentRoute.value == item.route;

      return InkWell(
        onTap: item.onTap ?? () => _navigate(item.route),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            ],
          ),
        ),
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
        top: 24,
        bottom: 24 + bottomPadding,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: controller.logout,
            child: Row(
              children: const [
                Icon(Icons.logout, color: AppColors.error),
                SizedBox(width: 16),
                Text(
                  'Logout',
                  style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'App Version 1.0.0',
            style: TextStyle(color: AppColors.textHint),
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
