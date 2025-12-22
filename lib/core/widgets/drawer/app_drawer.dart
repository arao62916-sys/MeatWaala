import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/core/theme/app_colors.dart';
import 'package:meatwaala_app/routes/app_routes.dart';
import 'package:meatwaala_app/core/widgets/drawer/app_drawer_controller.dart';
import 'package:meatwaala_app/core/widgets/drawer/drawer_menu_item.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject controller if not present
    final controller = Get.put(AppDrawerController());

    // Update route when drawer opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.currentRoute.value = Get.currentRoute;
    });

    // Calculate bottom padding required (Safe area only)
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    // Define menu items
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
        route: AppRoutes.orderHistory,
        onTap: () => _navigate(AppRoutes.orderHistory),
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
      // Column layout with Expanded list ensures proper spacing
      child: Column(
        children: [
          // 1. User Profile Header
          _buildHeader(context, controller),

          // 2. Navigation Menu (Expanded to fill available space)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(
                  top: 16, left: 12, right: 12, bottom: 0),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return _buildMenuItem(context, item, controller);
              },
            ),
          ),

          // 3. Bottom Section (Logout & App Info)
          // Passes dynamic bottom padding
          _buildFooter(context, controller, bottomPadding),
        ],
      ),
    );
  }

  /// Helper to handle navigation
  void _navigate(String route) {
    Get.back(); // Close drawer first
    if (Get.currentRoute != route) {
      Get.toNamed(route);
    }
  }

  /// Builds the top header section
  Widget _buildHeader(BuildContext context, AppDrawerController controller) {
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
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(28),
          ),
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
              // Profile Image
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
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
              ),
              const SizedBox(width: 16),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Guest User',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? user?.phone ?? 'Sign In',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.7),
                size: 16,
              ),
            ],
          );
        }),
      ),
    );
  }

  /// Builds individual menu items
  Widget _buildMenuItem(BuildContext context, DrawerMenuItem item,
      AppDrawerController controller) {
    return Obx(() {
      final bool isActive = controller.currentRoute.value == item.route;

      return Container(
        margin: const EdgeInsets.only(bottom: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: item.onTap ?? () => _navigate(item.route),
            borderRadius: BorderRadius.circular(12),
            splashColor: AppColors.primary.withOpacity(0.1),
            highlightColor: AppColors.primary.withOpacity(0.05),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary.withOpacity(0.1) : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    size: 24,
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
                  if (item.showBadge && (item.badgeCount ?? 0) > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${item.badgeCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  /// Builds the footer section with dynamic bottom padding
  Widget _buildFooter(BuildContext context, AppDrawerController controller,
      double bottomPadding) {
    return Container(
      // Apply padding: standard top/horizontal, standard bottom + safe area
      padding: EdgeInsets.only(
          left: 24, right: 24, top: 24, bottom: 24 + bottomPadding),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.divider.withOpacity(0.5),
          ),
        ),
      ),
      child: Column(
        children: [
          // Logout Button
          InkWell(
            onTap: controller.logout,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.logout, color: AppColors.error),
                  const SizedBox(width: 16),
                  Text(
                    'Logout',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // App Version Info
          Text(
            'App Version 1.0.0',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textHint,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Powered by MeatWaala',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textHint,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

// Local helper colors for header gradient
class UserColors {
  static const Color headerBgStart = Color(0xFFD32F2F); // AppColors.primary
  static const Color headerBgEnd = Color(0xFFB71C1C); // AppColors.primaryDark
}
