import 'package:get/get.dart';
import 'package:meatwaala_app/core/services/app_snackbar.dart';
import 'package:meatwaala_app/data/models/order_detail_model.dart';
import 'package:meatwaala_app/data/services/order_api_service.dart';
import 'package:meatwaala_app/services/storage_service.dart';
import 'package:meatwaala_app/routes/app_routes.dart';

class OrderController extends GetxController {
  final OrderApiService _orderService = OrderApiService();
  final StorageService _storage = StorageService();

  // Observable state
  final orders = <OrderSummaryModel>[].obs;
  final Rxn<OrderDetailModel> selectedOrder = Rxn<OrderDetailModel>();
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isReviewSubmitting = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  /// Load order list
  Future<void> loadOrders() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _orderService.getOrderList();

      if (result.success && result.data != null) {
        orders.value = result.data!;
      } else {
        errorMessage.value = result.message;
        if (!result.message.toLowerCase().contains('empty')) {
          AppSnackbar.error(result.message);
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to load orders';
      AppSnackbar.error('Failed to load orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load order details
  Future<void> loadOrderDetails(String orderId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _orderService.getOrderDetails(orderId);

      if (result.success && result.data != null) {
        selectedOrder.value = result.data;
      } else {
        errorMessage.value = result.message;
        AppSnackbar.error(result.message);
      }
    } catch (e) {
      errorMessage.value = 'Failed to load order details';
      AppSnackbar.error('Failed to load order details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Submit order
  Future<bool> submitOrder({
    required String paymentId,
    required String addressLine1,
    required String addressLine2,
    String? addressLine3,
    String? pincode,
    String? remarks,
  }) async {
    try {
      // Validate profile first
      final validation = _storage.validateProfileForOrder();
      if (!validation.isComplete) {
        AppSnackbar.warning(
          'Please complete your profile first.\n${validation.missingFieldsMessage}',
          title: 'Incomplete Profile',
        );

        // Redirect to profile edit screen
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.toNamed(AppRoutes.profile);
        });
        return false;
      }

      isSubmitting.value = true;

      final result = await _orderService.submitOrder(
        name: validation.name!,
        mobile: validation.mobile!,
        emailId: validation.email!,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        addressLine3: addressLine3,
        areaId: validation.areaId!,
        paymentId: paymentId,
        pincode: pincode,
        remarks: remarks,
      );

      if (result.success) {
        AppSnackbar.success('Order placed successfully!');

        // Refresh order list
        await loadOrders();

        return true;
      } else {
        AppSnackbar.error(result.message, title: 'Order Failed');
        return false;
      }
    } catch (e) {
      AppSnackbar.error('Failed to submit order: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Submit product review
  Future<bool> submitReview({
    required String orderItemId,
    required int rating,
    required String reviewTitle,
    required String review,
  }) async {
    try {
      if (rating < 1 || rating > 5) {
        AppSnackbar.warning('Please select a rating between 1 and 5',
            title: 'Invalid Rating');
        return false;
      }

      if (reviewTitle.trim().isEmpty || review.trim().isEmpty) {
        AppSnackbar.warning('Please fill in both title and review',
            title: 'Incomplete Review');
        return false;
      }

      isReviewSubmitting.value = true;

      final result = await _orderService.submitReview(
        orderItemId: orderItemId,
        rating: rating,
        reviewTitle: reviewTitle,
        review: review,
      );

      if (result.success) {
        AppSnackbar.success('Review submitted successfully!');

        // Refresh order details to show updated review status
        if (selectedOrder.value != null) {
          await loadOrderDetails(selectedOrder.value!.orderId);
        }

        return true;
      } else {
        AppSnackbar.error(result.message, title: 'Review Failed');
        return false;
      }
    } catch (e) {
      AppSnackbar.error('Failed to submit review: $e');
      return false;
    } finally {
      isReviewSubmitting.value = false;
    }
  }

  /// Check if user can submit review for an item
  bool canReviewItem(OrderItemModel item) {
    if (selectedOrder.value == null) return false;
    return selectedOrder.value!.canReview && !item.isReviewed;
  }

  /// Refresh orders
  Future<void> refreshOrders() async {
    await loadOrders();
  }

  /// Navigate to order details
  void viewOrderDetails(String orderId) {
    // TODO: Add AppRoutes.orderDetails to app_routes.dart
    // Get.toNamed(AppRoutes.orderDetails, arguments: {'orderId': orderId});
    // For now, load order details directly
    loadOrderDetails(orderId);
  }
}
