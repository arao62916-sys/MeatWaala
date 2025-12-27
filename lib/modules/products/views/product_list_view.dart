import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/core/theme/app_colors.dart';
import 'package:meatwaala_app/modules/products/controllers/product_list_controller.dart';
import 'package:meatwaala_app/modules/products/views/widgets/product_widgets.dart';

class ProductListView extends GetView<ProductListController> {
  const ProductListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              controller.categoryName.value.isEmpty
                  ? 'All Products'
                  : controller.categoryName.value,
            )),
        actions: [
          // Search Icon
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
          // Sort Icon
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortOptions(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Obx(() {
        // Loading State
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error State
        if (controller.errorMessage.value.isNotEmpty &&
            controller.products.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error.withOpacity(0.7),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Oops! Something went wrong',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.errorMessage.value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: controller.refreshProducts,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }

        // Empty State
        if (controller.products.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No products found',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your filters',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  if (controller.searchQuery.value.isNotEmpty ||
                      controller.selectedSortKey.value.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: controller.clearFilters,
                      icon: const Icon(Icons.clear_all),
                      label: const Text('Clear Filters'),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        // Success State - Show Products
        return RefreshIndicator(
          onRefresh: controller.refreshProducts,
          child: Column(
            children: [
              // Active Filters Chip
              if (controller.selectedSortOrder.value.isNotEmpty ||
                  controller.searchQuery.value.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: Colors.grey[100],
                  child: Row(
                    children: [
                      if (controller.searchQuery.value.isNotEmpty)
                        Chip(
                          label:
                              Text('Search: ${controller.searchQuery.value}'),
                          onDeleted: () => controller.clearFilters(),
                          deleteIcon: const Icon(Icons.close, size: 16),
                        ),
                      if (controller.selectedSortOrder.value.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Chip(
                            label: Text(controller.selectedSortOrder.value),
                            onDeleted: () {
                              controller.selectedSortKey.value = '';
                              controller.selectedSortOrder.value = '';
                              controller.loadProducts();
                            },
                            deleteIcon: const Icon(Icons.close, size: 16),
                          ),
                        ),
                    ],
                  ),
                ),

              // Product Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: controller.products.length,
                  itemBuilder: (context, index) {
                    final product = controller.products[index];
                    return ProductGridCard(
                      product: product,
                      onTap: () => controller.navigateToProductDetail(product),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// Show search dialog
  void _showSearchDialog(BuildContext context) {
    final searchController = TextEditingController(
      text: controller.searchQuery.value,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Products'),
          content: TextField(
            controller: searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter product name...',
              prefixIcon: Icon(Icons.search),
            ),
            onSubmitted: (value) {
              controller.searchProducts(value);
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                controller.searchProducts(searchController.text);
                Navigator.pop(context);
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  /// Show sort options bottom sheet
  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Obx(() {
          final sortOptions = controller.sortOptions;

          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  'Sort By',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // Sort Options
                if (sortOptions.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No sort options available'),
                    ),
                  )
                else
                  ...sortOptions.entries.map((entry) {
                    final isSelected =
                        controller.selectedSortKey.value == entry.key;

                    return RadioListTile<String>(
                      title: Text(entry.value),
                      value: entry.key,
                      groupValue: controller.selectedSortKey.value,
                      selected: isSelected,
                      onChanged: (value) {
                        if (value != null) {
                          controller.applySortOrder(value, entry.value);
                          Navigator.pop(context);
                        }
                      },
                    );
                  }),

                const SizedBox(height: 8),
              ],
            ),
          );
        });
      },
    );
  }
}
