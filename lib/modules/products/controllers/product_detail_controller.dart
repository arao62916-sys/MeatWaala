import 'package:get/get.dart';
import 'package:meatwaala_app/data/models/product_model.dart';
import 'package:meatwaala_app/data/repositories/mock_data_repository.dart';
import 'package:meatwaala_app/routes/app_routes.dart';

class ProductDetailController extends GetxController {
  final product = Rxn<ProductModel>();
  final selectedWeight = ''.obs;
  final quantity = 1.obs;
  final currentImageIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    final productId = args?['productId'] ?? '';
    loadProduct(productId);
  }

  void loadProduct(String productId) {
    product.value = MockDataRepository.getProductById(productId);
    if (product.value != null && product.value!.availableWeights.isNotEmpty) {
      selectedWeight.value = product.value!.availableWeights.first;
    }
  }

  void selectWeight(String weight) {
    selectedWeight.value = weight;
  }

  void incrementQuantity() {
    quantity.value++;
  }

  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  void onImageChanged(int index) {
    currentImageIndex.value = index;
  }

  double get currentPrice {
    if (product.value == null) return 0;
    return product.value!.getPriceForWeight(selectedWeight.value);
  }

  double get totalPrice {
    return currentPrice * quantity.value;
  }

  void addToCart() {
    if (product.value == null) return;

    // In a real app, this would use a cart service/controller
    Get.snackbar(
      'Added to Cart',
      '${product.value!.name} (${selectedWeight.value}) x ${quantity.value}',
      snackPosition: SnackPosition.BOTTOM,
    );

    // Navigate to cart
    Future.delayed(const Duration(seconds: 1), () {
      Get.toNamed(AppRoutes.cart);
    });
  }
}
