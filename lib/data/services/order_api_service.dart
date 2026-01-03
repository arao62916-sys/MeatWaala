import 'package:meatwaala_app/core/network/base_api_service.dart';
import 'package:meatwaala_app/core/network/network_constents.dart';
import 'package:meatwaala_app/data/models/order_detail_model.dart';
import 'package:meatwaala_app/services/storage_service.dart';

class OrderApiService {
  final BaseApiService _apiService = BaseApiService();
  final StorageService _storage = StorageService();

  /// Get customer_id from storage
  String? get customerId => _storage.getUserId();

  /// Validate customer ID
  bool _validateCustomerId() {
    return customerId != null && customerId!.isNotEmpty;
  }

  Future<ApiResult<Map<String, dynamic>>> submitOrder({
    required String name,
    required String mobile,
    required String emailId,
    required String addressLine1,
    required String addressLine2,
    required String areaId,
    required String paymentId,
    String? addressLine3,
    String? pincode,
    String? remarks,
  }) async {
    if (!_validateCustomerId()) {
      return ApiResult.error('Customer ID not found. Please login.');
    }

    final endpoint = '${NetworkConstantsUtil.orderSubmit}/$customerId';

    final fields = {
      'name': name,
      'mobile': mobile,
      'email_id': emailId,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'area_id': areaId,
      'payment_id': paymentId,
    };

    // Add optional fields
    if (addressLine3 != null && addressLine3.isNotEmpty) {
      fields['address_line3'] = addressLine3;
    }
    if (pincode != null && pincode.isNotEmpty) {
      fields['pincode'] = pincode;
    }
    if (remarks != null && remarks.isNotEmpty) {
      fields['remarks'] = remarks;
    }

    return await _apiService.postMultipart(
      endpoint,
      fields: fields,
      parser: (data) {
        if (data is Map<String, dynamic>) {
          return data;
        }
        return <String, dynamic>{};
      },
    );
  }

  /// Get Order List
  /// GET: order/list/{customer_id}
  Future<ApiResult<List<OrderSummaryModel>>> getOrderList() async {
    if (!_validateCustomerId()) {
      return ApiResult.error('Customer ID not found. Please login.');
    }

    final endpoint = '${NetworkConstantsUtil.orderList}/$customerId';

    return await _apiService.get(
      endpoint,
      parser: (data) {
        if (data is List) {
          return data.map((e) => OrderSummaryModel.fromJson(e)).toList();
        } else if (data is Map && data.containsKey('aOrder')) {
          // Handle wrapped response
          final orders = data['aOrder'];
          if (orders is List) {
            return orders.map((e) => OrderSummaryModel.fromJson(e)).toList();
          } else if (orders is Map) {
            return orders.values
                .map((e) => OrderSummaryModel.fromJson(e))
                .toList();
          }
        }
        return <OrderSummaryModel>[];
      },
    );
  }

  /// Get Order Details
  /// GET: order/info/{customer_id}/{order_id}
  Future<ApiResult<OrderDetailModel>> getOrderDetails(String orderId) async {
    if (!_validateCustomerId()) {
      return ApiResult.error('Customer ID not found. Please login.');
    }

    final endpoint = '${NetworkConstantsUtil.orderInfo}/$customerId/$orderId';

    return await _apiService.get(
      endpoint,
      parser: (data) {
        if (data is Map<String, dynamic>) {
          return OrderDetailModel.fromJson(data);
        }
        throw Exception('Invalid order data');
      },
    );
  }

  /// Submit Product Review
  /// POST: order/review/{customer_id}/{order_item_id}
  Future<ApiResult<Map<String, dynamic>>> submitReview({
    required String orderItemId,
    required int rating,
    required String reviewTitle,
    required String review,
  }) async {
    if (!_validateCustomerId()) {
      return ApiResult.error('Customer ID not found. Please login.');
    }

    if (rating < 1 || rating > 5) {
      return ApiResult.error('Rating must be between 1 and 5');
    }

    final endpoint =
        '${NetworkConstantsUtil.orderReview}/$customerId/$orderItemId';

    return await _apiService.postWithTokenOnly(
      endpoint,
      body: {
        'rating': rating,
        'review_title': reviewTitle,
        'review': review,
      },
      parser: (data) {
        if (data is Map<String, dynamic>) {
          return data;
        }
        return <String, dynamic>{};
      },
    );
  }
}
