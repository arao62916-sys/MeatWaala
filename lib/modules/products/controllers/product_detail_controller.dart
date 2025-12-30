import 'package:get/get.dart';
import 'package:meatwaala_app/data/models/product_model.dart';
import 'package:meatwaala_app/data/services/product_api_service.dart';
import 'package:meatwaala_app/data/services/cart_api_service.dart';
import 'package:meatwaala_app/modules/cart/controllers/cart_controller.dart';
import 'package:meatwaala_app/routes/app_routes.dart';

class ProductDetailController extends GetxController {
  final ProductApiService _productService = ProductApiService();
  final CartApiService _cartService = CartApiService();

  // State
  final RxBool isLoading = false.obs;
  final RxBool isAddingToCart = false.obs;
  final RxString errorMessage = ''.obs;

  // Data
  final Rxn<ProductDetailModel> productDetail = Rxn<ProductDetailModel>();
  final RxInt quantity = 1.obs;
  final RxInt currentImageIndex = 0.obs;
  final RxBool showFullDescription = false.obs;

  String productId = '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    productId = args?['productId']?.toString() ?? '';

    if (productId.isNotEmpty) {
      loadProductDetail();
    }
  }

  /// Load product detail from API
  Future<void> loadProductDetail() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _productService.getProductInfo(productId);

      if (result.success && result.data != null) {
        productDetail.value = result.data;
      } else {
        errorMessage.value = result.message;
        Get.snackbar(
          'Error',
          result.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      errorMessage.value = 'Failed to load product details';
      Get.snackbar(
        'Error',
        'Failed to load product details: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Increment quantity
  void incrementQuantity() {
    quantity.value++;
  }

  /// Decrement quantity
  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  /// Change current image
  void onImageChanged(int index) {
    currentImageIndex.value = index;
  }

  /// Toggle description
  void toggleDescription() {
    showFullDescription.value = !showFullDescription.value;
  }

  /// Get total price
  double get totalPrice {
    if (productDetail.value == null) return 0.0;
    return productDetail.value!.priceDouble * quantity.value;
  }

  /// Get total MRP
  double get totalMrp {
    if (productDetail.value == null) return 0.0;
    return productDetail.value!.mrpDouble * quantity.value;
  }

  /// Get savings
  double get savings {
    return totalMrp - totalPrice;
  }

  /// Get all product images (main + additional)
  List<String> get allImages {
    if (productDetail.value == null) return [];

    final images = <String>[productDetail.value!.imageUrl];

    if (productDetail.value!.aImage.isNotEmpty) {
      images.addAll(
        productDetail.value!.aImage.map((img) => img.image),
      );
    }

    return images;
  }

  // Compatibility getters for UI
  Rxn<ProductDetailModel> get product => productDetail;
  RxString selectedWeight = ''.obs;

  void selectWeight(String weight) {
    selectedWeight.value = weight;
  }

  /// Get reviews list
  List<ProductReviewModel> get reviews {
    if (productDetail.value == null) return [];
    return productDetail.value!.aReview.values.toList();
  }

  /// Add to cart
  Future<void> addToCart() async {
    if (productDetail.value == null) return;

    try {
      isAddingToCart.value = true;

      final result = await _cartService.addToCart(
        productId: productId,
        quantity: quantity.value,
      );

      if (result.success) {
        // Update cart controller if it exists
        if (Get.isRegistered<CartController>()) {
          final cartController = Get.find<CartController>();
          await cartController.refreshCart();
        }

        Get.snackbar(
          'Success',
          '${productDetail.value!.name} added to cart',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );

        // Navigate to cart after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.toNamed(AppRoutes.cart);
        });
      } else {
        Get.snackbar(
          'Error',
          result.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add to cart: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isAddingToCart.value = false;
    }
  }

  /// Refresh product detail
  Future<void> refreshProduct() async {
    await loadProductDetail();
  }
}
