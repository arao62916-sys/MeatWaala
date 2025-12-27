import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
                  onPressed: controller.refreshProducts,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Empty State
        if (controller.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No products found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                if (controller.searchQuery.value.isNotEmpty ||
                    controller.selectedSortKey.value.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.clearFilters,
                    child: const Text('Clear Filters'),
                  ),
                ],
              ],
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
