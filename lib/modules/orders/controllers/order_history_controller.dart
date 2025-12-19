import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/core/constants/app_constants.dart';
import 'package:meatwaala_app/data/models/order_model.dart';
import 'package:meatwaala_app/data/models/cart_item_model.dart';
import 'package:meatwaala_app/data/models/address_model.dart';
import 'package:meatwaala_app/data/repositories/mock_data_repository.dart';

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

    // Mock orders
    final products = MockDataRepository.getProducts();
    orders.value = [
      OrderModel(
        id: 'ORD001',
        userId: 'user_001',
        items: [
          CartItemModel(
            id: '1',
            product: products[0],
            selectedWeight: '500g',
            quantity: 2,
            price: products[0].basePrice,
          ),
        ],
        deliveryAddress: AddressModel(
          id: '1',
          title: 'Home',
          fullName: 'John Doe',
          phone: '+91 9876543210',
          addressLine1: '123 Main Street',
          city: 'Mumbai',
          state: 'Maharashtra',
          pincode: '400001',
        ),
        deliveryTimeSlot: '9:00 AM - 12:00 PM',
        paymentMethod: 'Cash on Delivery',
        subtotal: 560,
        deliveryFee: 40,
        total: 600,
        status: AppConstants.orderStatusDelivered,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        deliveredAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      OrderModel(
        id: 'ORD002',
        userId: 'user_001',
        items: [
          CartItemModel(
            id: '2',
            product: products[2],
            selectedWeight: '1kg',
            quantity: 1,
            price: products[2].basePrice,
          ),
        ],
        deliveryAddress: AddressModel(
          id: '1',
          title: 'Home',
          fullName: 'John Doe',
          phone: '+91 9876543210',
          addressLine1: '123 Main Street',
          city: 'Mumbai',
          state: 'Maharashtra',
          pincode: '400001',
        ),
        deliveryTimeSlot: '3:00 PM - 6:00 PM',
        paymentMethod: 'UPI',
        subtotal: 1280,
        deliveryFee: 40,
        total: 1320,
        status: AppConstants.orderStatusOutForDelivery,
        createdAt: DateTime.now(),
      ),
    ];

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
