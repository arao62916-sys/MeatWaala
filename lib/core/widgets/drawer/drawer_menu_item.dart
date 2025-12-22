import 'package:flutter/material.dart';

/// Model class for drawer menu items
class DrawerMenuItem {
  final String title;
  final IconData icon;
  final String route;
  final bool showBadge;
  final int? badgeCount;
  final VoidCallback? onTap;

  const DrawerMenuItem({
    required this.title,
    required this.icon,
    required this.route,
    this.showBadge = false,
    this.badgeCount,
    this.onTap,
  });
}
