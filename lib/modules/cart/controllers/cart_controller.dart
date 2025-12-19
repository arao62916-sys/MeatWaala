import 'package:get/get.dart';
import 'package:meatwaala_app/data/models/cart_item_model.dart';
import 'package:meatwaala_app/data/repositories/mock_data_repository.dart';
import 'package:meatwaala_app/routes/app_routes.dart';

class CartController extends GetxController {
  final cartItems = <CartItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadMockCart();
  }

  void loadMockCart() {
    // Mock cart items for demonstration
    final products = MockDataRepository.getProducts();
    if (products.length >= 2) {
      cartItems.value = [
        CartItemModel(
          id: '1',
          product: products[0],
          selectedWeight: products[0].availableWeights.first,
          quantity: 2,
          price: products[0].basePrice,
        ),
        CartItemModel(
          id: '2',
          product: products[2],
          selectedWeight: products[2].availableWeights.first,
          quantity: 1,
          price: products[2].basePrice,
        ),
      ];
    }
  }

  double get subtotal {
    return cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  double get deliveryFee => 40.0;

  double get total => subtotal + deliveryFee;

  void updateQuantity(String itemId, int newQuantity) {
    final index = cartItems.indexWhere((item) => item.id == itemId);
    if (index != -1 && newQuantity > 0) {
      cartItems[index] = cartItems[index].copyWith(quantity: newQuantity);
      cartItems.refresh();
    }
  }

  void removeItem(String itemId) {
    cartItems.removeWhere((item) => item.id == itemId);
    Get.snackbar(
      'Removed',
      'Item removed from cart',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void proceedToCheckout() {
    if (cartItems.isEmpty) {
      Get.snackbar(
        'Empty Cart',
        'Please add items to cart',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    Get.toNamed(AppRoutes.checkout);
  }
}
