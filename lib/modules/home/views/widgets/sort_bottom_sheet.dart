import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/core/theme/app_colors.dart';
import 'package:meatwaala_app/modules/home/controllers/home_controller.dart';

class SortBottomSheet extends GetView<HomeController> {
  const SortBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sort Products',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Sort options list
          Obx(() {
            final sortOptions = controller.sortOptions;
            print('Sort Options✅: $sortOptions');
            if (sortOptions.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading sort options...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildSortOption(
                  context,
                  sortKey: null,
                  label: 'Default',
                  icon: Icons.refresh,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ...sortOptions.entries.map((entry) {
                  return _buildSortOption(
                    context,
                    sortKey: entry.key,
                    label: entry.value,
                    icon: _getIconForSortOption(entry.key),
                  );
                }),
              ],
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context, {
    required String? sortKey,
    required String label,
    required IconData icon,
  }) {
    return Obx(() {
      final isSelected = sortKey == controller.selectedSortKey.value;
      final isLoading = controller.isSortLoading.value;

      return InkWell(
        onTap: isLoading
            ? null
            : () {
                if (sortKey == null) {
                  controller.clearSort();
                } else {
                  controller.applySortOption(sortKey, label);
                }
              },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.border.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              // Label
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                ),
              ),

              // Selected indicator
              if (isSelected)
                Icon(
                  isLoading ? Icons.hourglass_empty : Icons.check_circle,
                  color: AppColors.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      );
    });
  }

  IconData _getIconForSortOption(String sortKey) {
    if (sortKey.contains('new_arrival')) {
      return Icons.fiber_new;
    } else if (sortKey.contains('name') && sortKey.contains('asc')) {
      return Icons.sort_by_alpha;
    } else if (sortKey.contains('name') && sortKey.contains('desc')) {
      return Icons.sort_by_alpha;
    } else if (sortKey.contains('price') && sortKey.contains('asc')) {
      return Icons.arrow_upward;
    } else if (sortKey.contains('price') && sortKey.contains('desc')) {
      return Icons.arrow_downward;
    } else if (sortKey.contains('rating')) {
      return Icons.star;
    }
    return Icons.sort;
  }
}
