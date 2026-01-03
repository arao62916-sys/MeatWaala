import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/data/models/order_model.dart';
import 'package:meatwaala_app/data/services/order_api_service.dart';

class OrderHistoryController extends GetxController {
  final orders = <OrderModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    isLoading.value = true;

    await Future.delayed(const Duration(milliseconds: 500));

    // TODO: Load orders from API
    Example: final result = await OrderApiService().getOrderList();
    // if (result.success) orders.value = result.data ?? [];

    // For now, return empty list
    orders.value = [];

    isLoading.value = false;
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
        return const Color(0xFF4CAF50);
      case 'Out for Delivery':
        return const Color(0xFF2196F3);
      case 'Processing':
        return const Color(0xFFFFC107);
      case 'Cancelled':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}
