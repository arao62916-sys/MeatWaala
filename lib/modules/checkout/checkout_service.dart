import 'dart:developer';
import 'package:meatwaala_app/core/network/base_api_service.dart';
import 'package:meatwaala_app/core/network/network_constents.dart';

class OrderService {
  final BaseApiService _apiService = BaseApiService();

  /// Submit order after payment
  ///
  /// Endpoint: base_url/order/submit/$customer_id
  ///
  /// Required fields:
  /// - name: Customer name (Mandatory)
  /// - mobile: Customer mobile (Mandatory)
  /// - email_id: Customer email (Mandatory)
  /// - address_line1: Address line 1 (Mandatory)
  /// - address_line2: Address line 2 (Mandatory)
  /// - area_id: Area ID (Mandatory)
  /// - payment_id: Transaction ID from payment gateway (Mandatory)
  /// - remarks: Order remarks (Optional)
  Future<String> submitOrder(
    String customerId,
    Map<String, String> orderData, {
    bool cod = false,
  }) async {
    print(
        '📦 OrderService: Preparing to submit order for customer: $customerId');
    try {
      final baseEndpoint = '${NetworkConstantsUtil.orderSubmit}/$customerId';
      final endpoint = cod ? '$baseEndpoint?cod=1' : baseEndpoint;

      log('📦 OrderService: Submitting order for customer: $customerId');
      log('📦 OrderService: Order data: $orderData, COD: $cod');

      // Validate mandatory fields (skip payment IDs for COD)
      _validateOrderData(orderData, isCod: cod);

      final result = await _apiService.postFormData<Map<String, dynamic>>(
        endpoint,
        fields: orderData,
      );

      if (result.success && result.data != null) {
        log('✅ OrderService: Order submitted successfully');
        log('✅ OrderService: Response data: ${result.data}');

        // Extract order ID from response
        final orderId = result.data?['order_id']?.toString() ??
            result.data?['orderId']?.toString() ??
            result.data?['id']?.toString() ??
            'ORD${DateTime.now().millisecondsSinceEpoch}';

        return orderId;
      } else {
        log('❌ OrderService: Order submission failed: ${result.message}');
        throw Exception(result.message.isNotEmpty
            ? result.message
            : 'Failed to submit order');
      }
    } catch (e) {
      log('❌ OrderService: Error submitting order: $e');
      rethrow;
    }
  }

  /// Validate required order data fields
  void _validateOrderData(Map<String, String> orderData, {bool isCod = false}) {
    final requiredFields = [
      'name',
      'mobile',
      'email_id',
      'address_line1',
      'address_line2',
      'area_id',
      if (!isCod) 'payment_id',
      if (!isCod) 'payment_order_id',
    ];

    final missingFields = <String>[];

    for (final field in requiredFields) {
      if (!orderData.containsKey(field) || orderData[field]?.isEmpty == true) {
        missingFields.add(field);
      }
    }

    if (missingFields.isNotEmpty) {
      log('❌ Missing required fields: ${missingFields.join(", ")}');
      throw Exception('Missing required fields: ${missingFields.join(", ")}');
    }

    // Validate email format
    final email = orderData['email_id']!;
    if (!_isValidEmail(email)) {
      throw Exception('Invalid email format');
    }

    // Validate mobile format
    final mobile = orderData['mobile']!;
    if (!_isValidMobile(mobile)) {
      throw Exception('Invalid mobile number format');
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool _isValidMobile(String mobile) {
    // Remove any non-digit characters
    final digits = mobile.replaceAll(RegExp(r'\D'), '');
    // Indian mobile numbers should be 10 digits (or 12 with country code)
    return digits.length == 10 || digits.length == 12;
  }

  /// Fetch order details by order ID
  // Future<Map<String, dynamic>?> fetchOrderDetails(String orderId) async {
  //   try {
  //     final endpoint = '${NetworkConstantsUtil.orderDetails}/$orderId';

  //     log('📦 OrderService: Fetching order details for: $orderId');

  //     final result = await _apiService.get<Map<String, dynamic>>(
  //       endpoint,
  //       parser: (data) => data as Map<String, dynamic>,
  //     );

  //     if (result.success && result.data != null) {
  //       log('✅ OrderService: Order details fetched successfully');
  //       return result.data;
  //     } else {
  //       log('❌ OrderService: Failed to fetch order details: ${result.message}');
  //       throw Exception(result.message);
  //     }
  //   } catch (e) {
  //     log('❌ OrderService: Error fetching order details: $e');
  //     rethrow;
  //   }
  // }

  // /// Fetch customer's order history
  // Future<List<Map<String, dynamic>>> fetchOrderHistory(String customerId) async {
  //   try {
  //     final endpoint = '${NetworkConstantsUtil.orderHistory}/$customerId';

  //     log('📦 OrderService: Fetching order history for customer: $customerId');

  //     final result = await _apiService.get<List<dynamic>>(
  //       endpoint,
  //       parser: (data) => data as List<dynamic>,
  //     );

  //     if (result.success && result.data != null) {
  //       log('✅ OrderService: Order history fetched successfully');
  //       return result.data!.map((e) => e as Map<String, dynamic>).toList();
  //     } else {
  //       log('❌ OrderService: Failed to fetch order history: ${result.message}');
  //       throw Exception(result.message);
  //     }
  //   } catch (e) {
  //     log('❌ OrderService: Error fetching order history: $e');
  //     rethrow;
  //   }
  // }

  // /// Cancel an order
  // Future<String> cancelOrder(String orderId, String reason) async {
  //   try {
  //     final endpoint = '${NetworkConstantsUtil.orderCancel}/$orderId';

  //     log('📦 OrderService: Cancelling order: $orderId');
  //     log('📦 OrderService: Reason: $reason');

  //     final result = await _apiService.postFormData<Map<String, dynamic>>(
  //       endpoint,
  //       fields: {'reason': reason},
  //     );

  //     if (result.success) {
  //       log('✅ OrderService: Order cancelled successfully');
  //       return result.message.isNotEmpty
  //           ? result.message
  //           : 'Order cancelled successfully';
  //     } else {
  //       log('❌ OrderService: Order cancellation failed: ${result.message}');
  //       throw Exception(result.message);
  //     }
  //   } catch (e) {
  //     log('❌ OrderService: Error cancelling order: $e');
  //     rethrow;
  //   }
  // }

  // /// Track order status
  // Future<Map<String, dynamic>?> trackOrder(String orderId) async {
  //   try {
  //     final endpoint = '${NetworkConstantsUtil.orderTrack}/$orderId';

  //     log('📦 OrderService: Tracking order: $orderId');

  //     final result = await _apiService.get<Map<String, dynamic>>(
  //       endpoint,
  //       parser: (data) => data as Map<String, dynamic>,
  //     );

  //     if (result.success && result.data != null) {
  //       log('✅ OrderService: Order tracking info fetched successfully');
  //       return result.data;
  //     } else {
  //       log('❌ OrderService: Failed to track order: ${result.message}');
  //       throw Exception(result.message);
  //     }
  //   } catch (e) {
  //     log('❌ OrderService: Error tracking order: $e');
  //     rethrow;
  //   }
  // }
}
