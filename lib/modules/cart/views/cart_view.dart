import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:meatwaala_app/core/theme/app_colors.dart';
import 'package:meatwaala_app/core/widgets/custom_button.dart';
import 'package:meatwaala_app/modules/cart/controllers/cart_controller.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          // Area badge
          Obx(() {
            final areaName = controller.areaName.value;
            final deliveryCharge = controller.shippingCharge.value;
            if (areaName.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.delivery_dining,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '₹$deliveryCharge',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          // Cart count badge
          Obx(() => controller.cartCount.value > 0
              ? Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Center(
                    child: Text(
                      '${controller.cartCount.value} items',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.cartItems.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.cartItems.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Your cart is empty',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add items to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshCart,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: controller.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = controller.cartItems[index];
                    // Safely compute weight text (handles CartItemModel or raw Map)
                    String weightText() {
                      try {
                        if (item is Map) {
                          final Map m = item as Map;
                          final w = (m['weight'] ?? m['selectedWeight'] ?? '')
                              .toString();
                          final u = (m['weight_unit'] ??
                                  m['weightUnit'] ??
                                  m['unit'] ??
                                  '')
                              .toString();
                          return w.isNotEmpty
                              ? (u.isNotEmpty ? '$w $u' : w)
                              : '';
                        }
                        // assume model-like
                        final w = (item.selectedWeight ?? '').toString();
                        final u = (item.weightUnit ?? '').toString();
                        return w.isNotEmpty ? (u.isNotEmpty ? '$w $u' : w) : '';
                      } catch (_) {
                        return '';
                      }
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: item.productImage,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: AppColors.border.withOpacity(0.3),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: AppColors.border.withOpacity(0.3),
                                  child: const Icon(
                                    Icons.image_not_supported_outlined,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Product Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.selectedWeight}${item.weightUnit.isNotEmpty ? ' ${item.weightUnit}' : ''}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '₹${item.price}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Quantity Controls
                            Column(children: [
                              Container(
                                height: 50,

                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.border),
                                ),
                                // alignment: Alignment.centerRight,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            controller.updateQuantity(
                                              item.productId,
                                              item.quantity - 1,
                                            );
                                          },
                                          icon: const Icon(
                                              Icons.remove_circle_outline),
                                          color: AppColors.primary,
                                          iconSize: 20,
                                        ),
                                        Text(
                                          '${item.quantity}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            controller.updateQuantity(
                                              item.productId,
                                              item.quantity + 1,
                                            );
                                          },
                                          icon: const Icon(
                                              Icons.add_circle_outline),
                                          color: AppColors.primary,
                                          iconSize: 20,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    controller.removeItem(item.cartItemId),
                                child: const Text(
                                  'Remove',
                                  style: TextStyle(color: AppColors.error),
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Price Summary
            Container(
              padding: const EdgeInsets.all(16.0),
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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal'),
                      Obx(() => Text(
                            '₹${controller.subtotal.value.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          )),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() {
                        final areaName = controller.areaName.value;
                        return Text(
                          areaName.isNotEmpty
                              ? 'Delivery Fee ($areaName)'
                              : 'Delivery Fee',
                        );
                      }),
                      Obx(() => Text(
                            '₹${controller.shippingCharge.value.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          )),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Obx(() => Text(
                            '₹${controller.total.value.toStringAsFixed(2)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Proceed to Checkout',
                    onPressed: controller.proceedToCheckout,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
