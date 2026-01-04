import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:meatwaala_app/core/theme/app_colors.dart';
import 'package:meatwaala_app/core/widgets/custom_button.dart';
import 'package:meatwaala_app/modules/orders/views/order_list_view.dart';
import 'package:meatwaala_app/modules/products/controllers/product_detail_controller.dart';

class ProductDetailView extends GetView<ProductDetailController> {
  const ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Get.to(() => OrderListView());
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Obx(() {
        final product = controller.product.value;
        if (product == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Images
                    SizedBox(
                      height: 300,
                      child: PageView.builder(
                        itemCount: product.images.isNotEmpty
                            ? product.images.length
                            : 1,
                        onPageChanged: controller.onImageChanged,
                        itemBuilder: (context, index) {
                          final imageUrl = product.images.isNotEmpty
                              ? product.images[index]
                              : product.imageUrl;
                          return CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.border,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.border,
                              child: const Icon(Icons.error),
                            ),
                          );
                        },
                      ),
                    ),

                    // Image Indicators
                    if (product.images.length > 1)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            product.images.length,
                            (index) => Obx(() => Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: controller.currentImageIndex.value ==
                                            index
                                        ? AppColors.primary
                                        : AppColors.border,
                                  ),
                                )),
                          ),
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Name
                          Text(
                            product.name,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),

                          // Rating
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${product.rating} (${product.reviewCount} reviews)',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Description
                          Text(
                            'Description',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.description,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                          const SizedBox(height: 24),

                          // Weight Selection
                          Text(
                            'Select Weight',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: product.availableWeights.map((weight) {
                              return Obx(() => ChoiceChip(
                                    label: Text(weight),
                                    selected: controller.selectedWeight.value ==
                                        weight,
                                    onSelected: (selected) {
                                      if (selected) {
                                        controller.selectWeight(weight);
                                      }
                                    },
                                    selectedColor: AppColors.primary,
                                    labelStyle: TextStyle(
                                      color: controller.selectedWeight.value ==
                                              weight
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                    ),
                                  ));
                            }).toList(),
                          ),
                          const SizedBox(height: 24),

                          // Quantity Selection
                          Text(
                            'Quantity',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.border),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: controller.decrementQuantity,
                                      icon: const Icon(Icons.remove),
                                      color: AppColors.primary,
                                      padding: const EdgeInsets.all(8),
                                      constraints: const BoxConstraints(
                                        minWidth: 40,
                                        minHeight: 40,
                                      ),
                                    ),
                                    Obx(() => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          child: Text(
                                            '${controller.quantity.value}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        )),
                                    IconButton(
                                      onPressed: controller.incrementQuantity,
                                      icon: const Icon(Icons.add),
                                      color: AppColors.primary,
                                      padding: const EdgeInsets.all(8),
                                      constraints: const BoxConstraints(
                                        minWidth: 40,
                                        minHeight: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Total Price',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Obx(
                            () => Text(
                              '₹${controller.totalPrice.toStringAsFixed(2)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 150, // 🔑 fixed width prevents overflow
                      child: CustomButton(
                        text: 'Add to Cart',
                        onPressed: controller.addToCart,
                        icon: Icons.shopping_cart,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
