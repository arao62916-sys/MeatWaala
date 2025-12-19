import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/core/theme/app_colors.dart';
import 'package:meatwaala_app/modules/profile/controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24.0),
              color: AppColors.primary.withOpacity(0.1),
              child: Row(
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      controller.userName.value[0],
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => Text(
                              controller.userName.value,
                              style: Theme.of(context).textTheme.titleLarge,
                            )),
                        const SizedBox(height: 4),
                        Obx(() => Text(
                              controller.userEmail.value,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            )),
                        Obx(() => Text(
                              controller.userPhone.value,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Menu Items
            _buildMenuItem(
              icon: Icons.receipt_long,
              title: 'My Orders',
              onTap: controller.navigateToOrders,
            ),
            _buildMenuItem(
              icon: Icons.info_outline,
              title: 'About Us',
              onTap: controller.navigateToAboutUs,
            ),
            _buildMenuItem(
              icon: Icons.contact_support_outlined,
              title: 'Contact Us',
              onTap: controller.navigateToContactUs,
            ),
            _buildMenuItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: controller.navigateToPrivacyPolicy,
            ),
            _buildMenuItem(
              icon: Icons.description_outlined,
              title: 'Terms & Conditions',
              onTap: controller.navigateToTerms,
            ),
            const Divider(),
            _buildMenuItem(
              icon: Icons.logout,
              title: 'Logout',
              onTap: controller.logout,
              textColor: AppColors.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.textPrimary),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
