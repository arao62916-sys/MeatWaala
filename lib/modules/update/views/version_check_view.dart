import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/core/theme/app_colors.dart';
import 'package:meatwaala_app/modules/update/controllers/update_controller.dart';

class VersionCheckView extends GetView<UpdateController> {
  const VersionCheckView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.loadVersionInfo();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('App Version'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isChecking.value &&
            controller.currentVersion.value.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              _buildAppHeader(),
              const SizedBox(height: 28),
              _buildStatusBadge(),
              const SizedBox(height: 28),
              _buildVersionCard(
                title: 'Installed Version',
                version: controller.currentVersion.value,
                subtitle: 'Build ${controller.currentBuildNumber.value}',
                icon: Icons.phone_android_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(height: 14),
              _buildPlayStoreCard(),
              const SizedBox(height: 28),
              _buildActionButtons(),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAppHeader() {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.storefront_rounded,
            color: Colors.white,
            size: 44,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'MeatWaala',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Fresh Meat Delivery',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final isChecking = controller.isChecking.value;
    final hasError = controller.checkError.value.isNotEmpty;
    final updateAvailable = controller.isUpdateAvailable.value;

    Color bgColor;
    Color textColor;
    IconData icon;
    String label;

    if (isChecking) {
      bgColor = AppColors.info.withValues(alpha: 0.1);
      textColor = AppColors.info;
      icon = Icons.sync_rounded;
      label = 'Checking for updates...';
    } else if (hasError) {
      bgColor = AppColors.warning.withValues(alpha: 0.1);
      textColor = AppColors.warning;
      icon = Icons.wifi_off_rounded;
      label = controller.checkError.value;
    } else if (updateAvailable) {
      bgColor = AppColors.warning.withValues(alpha: 0.1);
      textColor = const Color(0xFFE65100);
      icon = Icons.arrow_circle_up_rounded;
      label = 'Update available';
    } else {
      bgColor = AppColors.success.withValues(alpha: 0.1);
      textColor = AppColors.success;
      icon = Icons.check_circle_rounded;
      label = 'You\'re up to date!';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          isChecking
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: textColor,
                  ),
                )
              : Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionCard({
    required String title,
    required String version,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  version.isEmpty ? '--' : 'v$version',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayStoreCard() {
    final hasError = controller.checkError.value.isNotEmpty;
    final updateAvailable = controller.isUpdateAvailable.value;
    final versionCode = controller.availableVersionCode.value;

    String version;
    String subtitle;
    Color color;

    if (hasError) {
      version = 'N/A';
      subtitle = 'Could not connect to Play Store';
      color = AppColors.textSecondary;
    } else if (updateAvailable && versionCode != null) {
      version = 'Build $versionCode';
      subtitle = 'New version ready to install';
      color = const Color(0xFFE65100);
    } else {
      version = controller.currentVersion.value;
      subtitle = 'Same as installed';
      color = AppColors.success;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: updateAvailable
            ? Border.all(
                color: const Color(0xFFE65100).withValues(alpha: 0.3),
                width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.shop_rounded, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Play Store Version',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasError ? version : 'v$version',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: updateAvailable
                        ? const Color(0xFFE65100)
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          if (updateAvailable)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE65100).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'NEW',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE65100),
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (controller.isUpdateAvailable.value)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: Obx(() => ElevatedButton.icon(
                  onPressed: controller.isUpdating.value
                      ? null
                      : () {
                          final isCritical =
                              controller.isUpdateAvailable.value;
                          if (isCritical) {
                            controller.startImmediateUpdate();
                          } else {
                            controller.startFlexibleUpdate();
                          }
                        },
                  icon: controller.isUpdating.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.download_rounded, size: 20),
                  label: Text(
                    controller.isUpdating.value ? 'Updating...' : 'Update Now',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                )),
          ),
        if (controller.isUpdateAvailable.value) const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed:
                controller.isChecking.value ? null : controller.loadVersionInfo,
            icon: controller.isChecking.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded, size: 20),
            label: Text(
              controller.isChecking.value ? 'Checking...' : 'Check Again',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.4),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
