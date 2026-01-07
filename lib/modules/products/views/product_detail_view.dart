import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:meatwaala_app/core/theme/app_colors.dart';
import 'package:meatwaala_app/core/widgets/custom_button.dart';
import 'package:meatwaala_app/modules/products/views/add_cart_animation.dart';
import 'package:meatwaala_app/modules/orders/views/order_list_view.dart';
import 'package:meatwaala_app/modules/products/controllers/product_detail_controller.dart';
import 'package:meatwaala_app/modules/cart/controllers/cart_controller.dart';
import 'package:meatwaala_app/data/models/product_model.dart';

class ProductDetailView extends GetView<ProductDetailController> {
  ProductDetailView({super.key});

  // Global keys for animation
  final GlobalKey _cartIconKey = GlobalKey();
  final GlobalKey _productImageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          // Simple cart icon without Obx wrapper
          _buildCartIcon(),
          const SizedBox(width: 4),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final product = controller.productDetail.value;
        if (product == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value.isEmpty
                      ? 'Product not found'
                      : controller.errorMessage.value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: controller.loadProductDetail,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshProduct,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Images Carousel
                      _buildImageCarousel(context, product),

                      // Product Info Section
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Name & Stock Status
                            _buildProductHeader(context, product),
                            const SizedBox(height: 12),

                            // Rating & Reviews
                            _buildRatingSection(context, product),
                            const SizedBox(height: 16),

                            // Price Section
                            _buildPriceSection(context, product),
                            const SizedBox(height: 24),

                            // Product Details
                            _buildProductDetails(context, product),
                            const SizedBox(height: 24),

                            // Description
                            _buildDescription(context, product),
                            const SizedBox(height: 24),

                            // Quantity Selection
                            _buildQuantitySelector(context),
                            const SizedBox(height: 24),

                            // Reviews Section
                            if (product.reviewsList.isNotEmpty) ...[
                              _buildReviewsSection(context, product),
                            ] else ...[
                              // Debug: Show when no reviews
                              Text(
                                'No reviews yet (Review count: ${product.reviewCount}, aReview length: ${product.aReview.length})',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Bottom Add to Cart Bar
            _buildBottomBar(context),
          ],
        );
      }),
    );
  }

  Widget _buildImageCarousel(BuildContext context, ProductDetailModel product) {
    final images = controller.allImages;
    
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: controller.onImageChanged,
            itemBuilder: (context, index) {
              return Container(
                key: index == 0 ? _productImageKey : null, // Assign key to first image
                child: CachedNetworkImage(
                  imageUrl: images[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.border,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.border,
                    child: const Icon(Icons.broken_image, size: 64),
                  ),
                ),
              );
            },
          ),
        ),
        
        // Image Indicators
        if (images.length > 1)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => Obx(() => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: controller.currentImageIndex.value == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: controller.currentImageIndex.value == index
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                )),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductHeader(BuildContext context, ProductDetailModel product) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Code: ${product.code}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: product.isInStock ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: product.isInStock ? Colors.green : Colors.red,
            ),
          ),
          child: Text(
            product.stockStatus,
            style: TextStyle(
              color: product.isInStock ? Colors.green.shade700 : Colors.red.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection(BuildContext context, ProductDetailModel product) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text(
                product.rating,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${product.reviewCount} reviews',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection(BuildContext context, ProductDetailModel product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${product.price}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '₹${product.mrp}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${((1 - product.priceDouble / product.mrpDouble) * 100).toStringAsFixed(0)}% OFF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'You save ₹${(product.mrpDouble - product.priceDouble).toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.green.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails(BuildContext context, ProductDetailModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildDetailRow('Weight', '${product.weight} ${product.weightUnit}'),
        _buildDetailRow('Packing', product.packing),
        _buildDetailRow('Category', product.category),
        _buildDetailRow('Menu', product.menu),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context, ProductDetailModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          final showFull = controller.showFullDescription.value;
          final description = product.description;
          final shouldTruncate = description.length > 200;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                shouldTruncate && !showFull
                    ? '${description.substring(0, 200)}...'
                    : description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              if (shouldTruncate)
                TextButton(
                  onPressed: controller.toggleDescription,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(showFull ? 'Show less' : 'Show more'),
                ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildQuantitySelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: controller.decrementQuantity,
                icon: const Icon(Icons.remove),
                color: AppColors.primary,
              ),
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '${controller.quantity.value}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )),
              IconButton(
                onPressed: controller.incrementQuantity,
                icon: const Icon(Icons.add),
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection(BuildContext context, ProductDetailModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Customer Reviews',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Show all reviews dialog or navigate to reviews page
                _showAllReviews(context, product);
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Show first 3 reviews
        ...product.reviewsList.take(3).map((review) => _buildReviewCard(context, review)),
      ],
    );
  }

  Widget _buildReviewCard(BuildContext context, ProductReviewModel review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    review.name[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < review.ratingDouble
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 16,
                              color: Colors.amber,
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            _formatReviewDate(review.reviewDate),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              review.reviewTitle,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              review.review,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return SafeArea(
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
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (controller.savings > 0)
                    Text(
                      'Save ₹${controller.savings.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Obx(() => SizedBox(
              width: 150,
              child: CustomButton(
                text: controller.isAddingToCart.value ? 'Adding...' : 'Add to Cart',
                onPressed: controller.isAddingToCart.value 
                    ? null 
                    : () => _handleAddToCart(context),
                icon: Icons.shopping_cart,
              ),
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAddToCart(BuildContext context) async {
    final product = controller.productDetail.value;
    if (product == null || controller.isAddingToCart.value) return;

    // Start animation
    await AddToCartAnimation.animate(
      context: context,
      imageUrl: product.imageUrl,
      startKey: _productImageKey,
      cartKey: _cartIconKey,
      onComplete: () async {
        // Call the actual add to cart logic
        await controller.addToCart();
        
        // Trigger cart icon bounce
        final cartIconState = _cartIconKey.currentState;
        if (cartIconState is AnimatedCartIconState) {
          cartIconState.bounce();
        }
      },
    );
  }

  String _formatReviewDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else if (difference.inDays < 30) {
        return '${(difference.inDays / 7).floor()} weeks ago';
      } else if (difference.inDays < 365) {
        return '${(difference.inDays / 30).floor()} months ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }

  void _showAllReviews(BuildContext context, ProductDetailModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Reviews (${product.reviewCount})',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: product.reviewsList.length,
                itemBuilder: (context, index) {
                  return _buildReviewCard(context, product.reviewsList[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build cart icon widget
  Widget _buildCartIcon() {
    // Check if CartController is registered
    if (Get.isRegistered<CartController>()) {
      return Obx(() {
        final cartController = Get.find<CartController>();
        return AnimatedCartIcon(
          iconKey: _cartIconKey,
          itemCount: cartController.cartItems.length,
          onPressed: () => Get.to(() => OrderListView()),
        );
      });
    } else {
      // Fallback without cart count
      return AnimatedCartIcon(
        iconKey: _cartIconKey,
        itemCount: 0,
        onPressed: () => Get.to(() => OrderListView()),
      );
    }
  }
}