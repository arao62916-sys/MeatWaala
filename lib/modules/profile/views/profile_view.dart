import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/core/theme/app_colors.dart';
import 'package:meatwaala_app/modules/profile/controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.errorMessage.value.isNotEmpty &&
            !controller.hasProfile) {
          return _buildErrorState(context);
        }

        return CustomScrollView(
          slivers: [
            _buildColorfulAppBar(context),

            // Pinned profile header that stays visible while content scrolls
            SliverPersistentHeader(
              pinned: true,
              delegate: _ProfileHeaderDelegate(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _buildProfileHeader(context),
                ),
              ),
            ),

            // Remaining content (menu list) scrolls under the pinned header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildMenuList(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load profile',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.fetchProfile,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorfulAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.primary,
      title: const Text(
        'My Profile',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      elevation: 0,
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Simple Circle Avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: controller.profileImage.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      controller.profileImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildInitialsAvatar();
                      },
                    ),
                  )
                : _buildInitialsAvatar(),
          ),
          const SizedBox(width: 10),

          // Name, Email, Phone in column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.userName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontSize: 17,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  controller.userEmail,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  controller.userPhone,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                ),
              ],
            ),
          ),

          // Edit button
          IconButton(
            onPressed: controller.navigateToEditProfile,
            icon: Icon(
              Icons.edit_outlined,
              color: AppColors.primary,
              size: 22,
            ),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialsAvatar() {
    return Center(
      child: Text(
        controller.userInitials,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildMenuList(BuildContext context) {
    return Column(
      children: [
        // Account Section
        _buildSectionTitle('Account'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildColorfulMenuItem(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                onTap: controller.navigateToEditProfile,
                color: AppColors.primary,
              ),
              _buildSimpleDivider(),
              _buildColorfulMenuItem(
                icon: Icons.lock_outline,
                title: 'Change Password',
                onTap: controller.navigateToChangePassword,
                color: AppColors.primary,
              ),
              _buildSimpleDivider(),
              _buildColorfulMenuItem(
                icon: Icons.receipt_long_outlined,
                title: 'My Orders',
                onTap: controller.navigateToOrders,
                color: AppColors.primary,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Support Section
        _buildSectionTitle('Support'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildColorfulMenuItem(
                icon: Icons.info_outline,
                title: 'About Us',
                onTap: controller.navigateToAboutUs,
                color: AppColors.primary,
              ),
              _buildSimpleDivider(),
              _buildColorfulMenuItem(
                icon: Icons.contact_support_outlined,
                title: 'Contact Us',
                onTap: controller.navigateToContactUs,
                color: AppColors.primary,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Legal Section
        _buildSectionTitle('Legal'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.indigo.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildColorfulMenuItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: controller.navigateToPrivacyPolicy,
                color: AppColors.primary,
              ),
              _buildSimpleDivider(),
              _buildColorfulMenuItem(
                icon: Icons.description_outlined,
                title: 'Terms & Conditions',
                onTap: controller.navigateToTerms,
                color: AppColors.primary,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Logout
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.error.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _buildColorfulMenuItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: controller.logout,
            color: AppColors.error,
            showArrow: false,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.primary.withOpacity(0.7),
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildColorfulMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color color,
    bool showArrow = true,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: color,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      trailing: showArrow
          ? Icon(
              Icons.chevron_right,
              color: color.withOpacity(0.5),
              size: 20,
            )
          : null,
    );
  }

  Widget _buildSimpleDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 68,
      endIndent: 16,
      color: Colors.grey.shade200,
    );
  }
}

// Move _ProfileHeaderDelegate outside of ProfileView
class _ProfileHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double minExtentHeight;
  final double maxExtentHeight;

  // Use equal min/max extents so the header doesn't shrink below the
  // content's intrinsic height and cause RenderFlex overflow.
  _ProfileHeaderDelegate(
      {required this.child,
      this.minExtentHeight = 140,
      this.maxExtentHeight = 140});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );
  }

  @override
  double get minExtent => minExtentHeight;

  @override
  double get maxExtent => maxExtentHeight;

  @override
  bool shouldRebuild(covariant _ProfileHeaderDelegate oldDelegate) {
    return oldDelegate.child != child ||
        oldDelegate.minExtentHeight != minExtentHeight ||
        oldDelegate.maxExtentHeight != maxExtentHeight;
  }
}
