import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Global Snackbar Service for consistent snackbar usage across the app
///
/// Usage:
/// - AppSnackbar.success('Operation successful!');
/// - AppSnackbar.error('Something went wrong');
/// - AppSnackbar.warning('Please check your input');
/// - AppSnackbar.info('New updates available');
class AppSnackbar {
  // Prevent instantiation
  AppSnackbar._();

  // Common configuration
  static const Duration _duration = Duration(seconds: 3);
  static const SnackPosition _position = SnackPosition.TOP;
  static const EdgeInsets _margin = EdgeInsets.all(10);
  static const double _borderRadius = 10.0;

  /// Show success snackbar (green)
  static void success(String message, {String? title}) {
    if (message.isEmpty) return;

    Get.snackbar(
      title ?? 'Success',
      message,
      snackPosition: _position,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      margin: _margin,
      borderRadius: _borderRadius,
      duration: _duration,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  /// Show error snackbar (red)
  static void error(String message, {String? title}) {
    if (message.isEmpty) return;

    Get.snackbar(
      title ?? 'Error',
      message,
      snackPosition: _position,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
      margin: _margin,
      borderRadius: _borderRadius,
      duration: _duration,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  /// Show warning snackbar (orange/amber)
  static void warning(String message, {String? title}) {
    if (message.isEmpty) return;

    Get.snackbar(
      title ?? 'Warning',
      message,
      snackPosition: _position,
      backgroundColor: Colors.orange.shade600,
      colorText: Colors.white,
      icon: const Icon(Icons.warning, color: Colors.white),
      margin: _margin,
      borderRadius: _borderRadius,
      duration: _duration,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  /// Show info snackbar (blue)
  static void info(String message, {String? title}) {
    if (message.isEmpty) return;

    Get.snackbar(
      title ?? 'Info',
      message,
      snackPosition: _position,
      backgroundColor: Colors.blue.shade600,
      colorText: Colors.white,
      icon: const Icon(Icons.info, color: Colors.white),
      margin: _margin,
      borderRadius: _borderRadius,
      duration: _duration,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  /// Show custom snackbar with custom colors and icon
  static void custom({
    required String title,
    required String message,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration? duration,
  }) {
    if (message.isEmpty) return;

    Get.snackbar(
      title,
      message,
      snackPosition: _position,
      backgroundColor: backgroundColor ?? Colors.grey.shade600,
      colorText: textColor ?? Colors.white,
      icon: icon != null ? Icon(icon, color: textColor ?? Colors.white) : null,
      margin: _margin,
      borderRadius: _borderRadius,
      duration: duration ?? _duration,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }
}
