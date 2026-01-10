import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/core/services/app_snackbar.dart';
import 'package:meatwaala_app/data/models/cart_item_model.dart';
import 'package:meatwaala_app/data/models/area_model.dart';
import 'package:meatwaala_app/data/services/cart_api_service.dart';
import 'package:meatwaala_app/data/services/area_api_service.dart';
import 'package:meatwaala_app/services/storage_service.dart';
import 'package:meatwaala_app/routes/app_routes.dart';

class CartController extends GetxController {
  final CartApiService _cartService = CartApiService();
  final AreaApiService _areaService = AreaApiService();
  final StorageService _storage = StorageService();

  // Observable state
  final cartItems = <CartItemModel>[].obs;
  final RxInt cartCount = 0.obs;
  final RxDouble subtotal = 0.0.obs;
  final RxDouble shippingCharge = 0.0.obs;
  final RxDouble discount = 0.0.obs;
  final RxDouble total = 0.0.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<AreaModel?> selectedArea = Rx<AreaModel?>(null);
  final RxString areaName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAreaInfo();
    loadCartInfo();
    loadCartCount();
  }

  /// Load area information from storage and fetch area details
  Future<void> loadAreaInfo() async {
    try {
      final areaId = _storage.getSelectedAreaId();
      areaName.value = _storage.getSelectedAreaName() ?? '';

      if (areaId != null && areaId.isNotEmpty) {
        log('🌍 CartController: Loading area info for area ID: $areaId');
        final result = await _areaService.getAreaInfo(areaId);

        if (result.success && result.data != null) {
          selectedArea.value = result.data;
          // Update delivery fee from area charge
          shippingCharge.value = result.data!.deliveryCharge;
          _recalculateTotals();
          log('✅ CartController: Area loaded - ${result.data!.name}, Delivery: ₹${result.data!.charge}');
        } else {
          log('⚠️ CartController: Failed to load area info: ${result.message}');
        }
      }
    } catch (e) {
      log('❌ CartController: Error loading area info: $e');
    }
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
          AppSnackbar.error(result.message, title: 'Oops!');
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to load cart';
      AppSnackbar.error('Failed to load cart: $e');
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
    print('Updating quantity✅✅ for productId=$productId to $newQuantity');
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
        AppSnackbar.success('Cart updated successfully', title: 'Updated');
      } else {
        // Revert optimistic update
        if (index != -1) {
          await loadCartInfo();
        }
        AppSnackbar.error(result.message);
      }
    } catch (e) {
      await loadCartInfo(); // Reload to get correct state
      AppSnackbar.error('Failed to update cart: $e');
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
        AppSnackbar.success('Item removed from cart', title: 'Removed');
      } else {
        // Revert if API fails
        await loadCartInfo();
        AppSnackbar.error(result.message, title: 'Oops!');
      }
    } catch (e) {
      await loadCartInfo(); // Reload to get correct state
      AppSnackbar.error('Failed to remove item: $e', title: 'Oops!');
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
      AppSnackbar.error('Please add items to cart', title: 'Empty Cart');
      return;
    }

    // Reload area info before checkout to ensure latest delivery charge
    loadAreaInfo().then((_) {
      Get.toNamed(AppRoutes.checkout, arguments: {
        'subtotal': subtotal.value,
        'deliveryFee': shippingCharge.value,
        'discount': discount.value,
        'total': total.value,
        'areaId': _storage.getSelectedAreaId(),
        'areaName': areaName.value,
      })?.then((_) {
        // Reload cart when returning from checkout in case area changed
        log('🔄 Returned from checkout, reloading cart...');
        loadAreaInfo();
        loadCartInfo();
      });
    });
  }

  /// Get delivery fee (backward compatibility)
  double get deliveryFee => shippingCharge.value;
}
