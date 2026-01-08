import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:meatwaala_app/core/theme/app_colors.dart';
import 'package:meatwaala_app/modules/categories/controllers/categories_controller.dart';

class CategoriesView extends GetView<CategoriesController> {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Obx(() {
            // Show loading indicator while menu is loading
            if (controller.isMenuLoading.value) {
              return Container(
                color: AppColors.primary,
                height: 48,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.textWhite,
                    strokeWidth: 2,
                  ),
                ),
              );
            }

            // Show tabs if menu categories are loaded
            if (controller.menuCategories.isEmpty) {
              return const SizedBox.shrink();
            }

            return Container(
              color: AppColors.primary,
              child: TabBar(
                controller: controller.tabController,
                isScrollable: true,
                indicatorColor: AppColors.textWhite,
                indicatorWeight: 3,
                labelColor: AppColors.textWhite,
                unselectedLabelColor: AppColors.textWhite.withOpacity(0.7),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                tabs: controller.menuCategories
                    .map((menu) => Tab(text: menu.name))
                    .toList(),
              ),
            );
          }),
        ),
      ),
      body: Obx(() {
        // Show menu loading state
        if (controller.isMenuLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // If no menu categories, show all categories in a single view
        if (controller.menuCategories.isEmpty) {
          return _buildCategoryGrid();
        }

        // Show tab view with menu categories
        return TabBarView(
          controller: controller.tabController,
          children: controller.menuCategories.map((menu) {
            return _buildCategoryGrid();
          }).toList(),
        );
      }),
    );
  }

  Widget _buildCategoryGrid() {
    return Obx(() {
      // Loading State
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // Error State
      if (controller.errorMessage.value.isNotEmpty &&
          controller.categories.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                controller.errorMessage.value,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.refreshCategories,
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      // Empty State
      if (controller.categories.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.category_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No categories available',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }

      // Success State - Show Categories
      return RefreshIndicator(
        onRefresh: controller.refreshCategories,
        child: GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75, // Adjusted for better proportions
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            return _buildCategoryCard(context, category);
          },
        ),
      );
    });
  }

  Widget _buildCategoryCard(BuildContext context, category) {
    return InkWell(
      onTap: () => controller.navigateToProductList(
        category.categoryId,
        category.name,
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category Image - Takes more space
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: CachedNetworkImage(
                  imageUrl: category.imageUrl,
                  fit: BoxFit.fill,
                  placeholder: (context, url) => Container(
                    color: AppColors.border.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.border.withOpacity(0.3),
                    child: const Icon(
                      Icons.fastfood,
                      size: 40,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),

            // Category Info - Compact text section
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (category.shortDescription != null &&
                        category.shortDescription!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        category.shortDescription!,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}