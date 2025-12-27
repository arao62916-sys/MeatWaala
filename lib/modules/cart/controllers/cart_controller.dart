import 'package:get/get.dart';
import 'package:meatwaala_app/data/models/cart_item_model.dart';
import 'package:meatwaala_app/routes/app_routes.dart';

class CartController extends GetxController {
  final cartItems = <CartItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadMockCart();
  }

  void loadMockCart() {
    // TODO: Load cart from API or local storage
    // Cart should be populated when user adds items from product detail page
    // For now, cart starts empty
    cartItems.value = [];
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
