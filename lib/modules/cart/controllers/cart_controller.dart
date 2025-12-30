import 'package:get/get.dart';
import 'package:meatwaala_app/data/models/cart_item_model.dart';
import 'package:meatwaala_app/data/services/cart_api_service.dart';
import 'package:meatwaala_app/routes/app_routes.dart';

class CartController extends GetxController {
  final CartApiService _cartService = CartApiService();

  // Observable state
  final cartItems = <CartItemModel>[].obs;
  final RxInt cartCount = 0.obs;
  final RxDouble subtotal = 0.0.obs;
  final RxDouble shippingCharge = 0.0.obs;
  final RxDouble discount = 0.0.obs;
  final RxDouble total = 0.0.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCartInfo();
    loadCartCount();
  }

  /// Load full cart information from API
  Future<void> loadCartInfo() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _cartService.getCartInfo();

      if (result.success && result.data != null) {
        final cartInfo = result.data!;
        cartItems.value = cartInfo.items;
        subtotal.value = cartInfo.subtotal;
        shippingCharge.value = cartInfo.shippingCharge;
        discount.value = cartInfo.discount;
        total.value = cartInfo.total;
        cartCount.value = cartInfo.itemCount;
      } else {
        errorMessage.value = result.message;
        // Don't show error for empty cart
        if (!result.message.toLowerCase().contains('empty')) {
          Get.snackbar(
            'Error',
            result.message,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to load cart';
      Get.snackbar(
        'Error',
        'Failed to load cart: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load cart count from API
  Future<void> loadCartCount() async {
    try {
      final result = await _cartService.getCartCount();
      if (result.success && result.data != null) {
        cartCount.value = result.data!;
      }
    } catch (e) {
      // Silent fail for cart count
      cartCount.value = cartItems.length;
    }
  }

  /// Update item quantity
  Future<void> updateQuantity(String productId, int newQuantity) async {
    if (newQuantity < 1) {
      return;
    }

    try {
      // Optimistically update UI
      final index = cartItems.indexWhere((item) => item.productId == productId);
      if (index != -1) {
        final oldItem = cartItems[index];
        cartItems[index] = oldItem.copyWith(quantity: newQuantity);
        cartItems.refresh();
        _recalculateTotals();
      }

      // Call API
      final result = await _cartService.updateCart(
        productId: productId,
        quantity: newQuantity,
      );

      if (result.success) {
        // Refresh cart to get updated totals from server
        await loadCartInfo();
        Get.snackbar(
          'Updated',
          'Cart updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1),
        );
      } else {
        // Revert optimistic update
        if (index != -1) {
          await loadCartInfo();
        }
        Get.snackbar(
          'Error',
          result.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      await loadCartInfo(); // Reload to get correct state
      Get.snackbar(
        'Error',
        'Failed to update cart: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Remove item from cart
  Future<void> removeItem(String cartItemId) async {
    try {
      // Optimistically remove from UI
      cartItems.removeWhere((item) => item.cartItemId == cartItemId);
      cartItems.refresh();
      _recalculateTotals();

      // Call API
      final result = await _cartService.removeCartItem(cartItemId: cartItemId);

      if (result.success) {
        await loadCartCount();
        Get.snackbar(
          'Removed',
          'Item removed from cart',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1),
        );
      } else {
        // Revert if API fails
        await loadCartInfo();
        Get.snackbar(
          'Error',
          result.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      await loadCartInfo(); // Reload to get correct state
      Get.snackbar(
        'Error',
        'Failed to remove item: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Recalculate totals locally (optimistic updates)
  void _recalculateTotals() {
    subtotal.value = cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
    total.value = subtotal.value + shippingCharge.value - discount.value;
  }

  /// Refresh cart (pull-to-refresh)
  Future<void> refreshCart() async {
    await Future.wait([
      loadCartInfo(),
      loadCartCount(),
    ]);
  }

  /// Proceed to checkout
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

  /// Get delivery fee (backward compatibility)
  double get deliveryFee => shippingCharge.value;
}
