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
      backgroundColor: AppColors.background,
      appBar: AppBar(
       
        title: const Text('App Version'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
      ),
      body: Obx(() {
        if (controller.isChecking.value &&
            controller.currentVersion.value.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Checking version...',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildAppHeader(),
              const SizedBox(height: 32),
              _buildStatusCard(),
              const SizedBox(height: 24),
              _buildVersionInfo(),
              const SizedBox(height: 24),
              _buildActionButtons(),
              const SizedBox(height: 16),
              _buildLastCheckedInfo(),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAppHeader() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Glow effect
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.15),
                          AppColors.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                  // App icon
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/icons/icon.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'MeatWaala',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Fresh Meat Delivery',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusCard() {
    final isChecking = controller.isChecking.value;
    final hasError = controller.checkError.value.isNotEmpty;
    final updateAvailable = controller.isUpdateAvailable.value;

    Color bgColor;
    Color borderColor;
    Color textColor;
    IconData icon;
    String title;
    String subtitle;

    if (isChecking) {
      bgColor = AppColors.info.withValues(alpha: 0.08);
      borderColor = AppColors.info.withValues(alpha: 0.3);
      textColor = AppColors.info;
      icon = Icons.sync_rounded;
      title = 'Checking for updates';
      subtitle = 'Please wait while we check the Play Store...';
    } else if (hasError) {
      bgColor = AppColors.warning.withValues(alpha: 0.08);
      borderColor = AppColors.warning.withValues(alpha: 0.3);
      textColor = AppColors.warning;
      icon = Icons.cloud_off_rounded;
      title = 'Connection Error';
      subtitle = controller.checkError.value;
    } else if (updateAvailable) {
      bgColor = const Color(0xFFE65100).withValues(alpha: 0.08);
      borderColor = const Color(0xFFE65100).withValues(alpha: 0.3);
      textColor = const Color(0xFFE65100);
      icon = Icons.system_update_rounded;
      title = 'Update Available!';
      subtitle = 'A new version is ready to install';
    } else {
      bgColor = AppColors.success.withValues(alpha: 0.08);
      borderColor = AppColors.success.withValues(alpha: 0.3);
      textColor = AppColors.success;
      icon = Icons.check_circle_rounded;
      title = 'You\'re Up to Date!';
      subtitle = 'You have the latest version installed';
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: updateAvailable
            ? [
                BoxShadow(
                  color: textColor.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: isChecking
                ? Padding(
                    padding: const EdgeInsets.all(14),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: textColor,
                    ),
                  )
                : Icon(icon, color: textColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo() {
    final hasError = controller.checkError.value.isNotEmpty;
    final updateAvailable = controller.isUpdateAvailable.value;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Current Version
          _buildVersionRow(
            icon: Icons.smartphone_rounded,
            iconColor: AppColors.primary,
            label: 'Installed Version',
            version: controller.currentVersion.value,
            buildNumber: 'Build ${controller.currentBuildNumber.value}',
            showDivider: true,
          ),
          
          // Play Store Version
          _buildVersionRow(
            icon: Icons.shop_rounded,
            iconColor: updateAvailable
                ? const Color(0xFFE65100)
                : AppColors.success,
            label: 'Play Store Version',
            version: hasError
                ? 'N/A'
                : controller.playStoreVersion.value.isNotEmpty
                    ? controller.playStoreVersion.value
                    : controller.currentVersion.value,
            buildNumber: hasError ? '' : 'Play Store',
            isPlayStore: true,
            showBadge: updateAvailable,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildVersionRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String version,
    required String buildNumber,
    bool isPlayStore = false,
    bool showBadge = false,
    bool showDivider = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (showBadge) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE65100).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFE65100),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          version.isEmpty ? '--' : 'v$version',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: showBadge 
                                ? const Color(0xFFE65100)
                                : AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (buildNumber.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              buildNumber,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              color: Colors.grey.shade200,
              height: 1,
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final updateAvailable = controller.isUpdateAvailable.value;
    final isUpdating = controller.isUpdating.value;
    final isChecking = controller.isChecking.value;

    return Column(
      children: [
        // Update button
        if (updateAvailable)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isUpdating
                  ? null
                  : () {
                      final isCritical = controller.isUpdateAvailable.value;
                      if (isCritical) {
                        controller.startImmediateUpdate();
                      } else {
                        controller.startFlexibleUpdate();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE65100),
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    const Color(0xFFE65100).withValues(alpha: 0.5),
                elevation: 0,
                shadowColor: const Color(0xFFE65100).withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isUpdating)
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  else
                    const Icon(Icons.download_rounded, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    isUpdating ? 'Downloading Update...' : 'Update Now',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        if (updateAvailable) const SizedBox(height: 12),

        // Check again button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: isChecking ? null : controller.loadVersionInfo,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(
                color: isChecking
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.5),
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isChecking)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primary,
                    ),
                  )
                else
                  const Icon(Icons.refresh_rounded, size: 22),
                const SizedBox(width: 10),
                Text(
                  isChecking ? 'Checking...' : 'Check for Updates',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLastCheckedInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 16,
          color: AppColors.textSecondary.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 6),
        Text(
          'Updates are checked automatically',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}