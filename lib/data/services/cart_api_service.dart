import 'package:meatwaala_app/core/network/base_api_service.dart';
import 'package:meatwaala_app/core/network/network_constents.dart';
import 'package:meatwaala_app/data/models/cart_item_model.dart';
import 'package:meatwaala_app/services/storage_service.dart';

class CartApiService {
  final BaseApiService _apiService = BaseApiService();
  final StorageService _storage = StorageService();

  /// Get customer_id from storage
  String? get customerId => _storage.getUserId();

  /// Get area_id from storage
  String? get areaId => _storage.getSelectedAreaId();

  /// Validate customer and area IDs
  bool _validateIds() {
    return customerId != null &&
        customerId!.isNotEmpty &&
        areaId != null &&
        areaId!.isNotEmpty;
  }

  /// Add item to cart
  /// POST: cart/add/{customer_id}/{area_id}
  /// Body: { "product_id": "string/int", "qty": "int", "action": "add" }
  Future<ApiResult<Map<String, dynamic>>> addToCart({
    required String productId,
    required int quantity,
  }) async {
    if (!_validateIds()) {
      return ApiResult.error(
        'Customer ID or Area ID not found. Please login and select area.',
      );
    }

    final endpoint = '${NetworkConstantsUtil.cartAdd}/$customerId/$areaId';

    return await _apiService.postWithTokenOnly(
      endpoint,
      body: {
        'product_id': productId,
        'qty': quantity,
        'action': 'add',
      },
      parser: (data) {
        if (data is Map<String, dynamic>) {
          return data;
        }
        return <String, dynamic>{};
      },
    );
  }

  /// Update cart item quantity
  /// POST: cart/add/{customer_id}/{area_id}
  /// Body: { "product_id": "string/int", "qty": "int", "action": "update" }
  Future<ApiResult<Map<String, dynamic>>> updateCart({
    required String productId,
    required int quantity,
  }) async {
    if (!_validateIds()) {
      return ApiResult.error(
        'Customer ID or Area ID not found. Please login and select area.',
      );
    }

    final endpoint = '${NetworkConstantsUtil.cartAdd}/$customerId/$areaId';

    return await _apiService.postWithTokenOnly(
      endpoint,
      body: {
        'product_id': productId,
        'qty': quantity,
        'action': 'update',
      },
      parser: (data) {
        if (data is Map<String, dynamic>) {
          return data;
        }
        return <String, dynamic>{};
      },
    );
  }

  /// Remove item from cart
  /// GET: cart/delete/{customer_id}/{area_id}?cart_item_id={id}
  Future<ApiResult<Map<String, dynamic>>> removeCartItem({
    required String cartItemId,
  }) async {
    if (!_validateIds()) {
      return ApiResult.error(
        'Customer ID or Area ID not found. Please login and select area.',
      );
    }

    final endpoint = '${NetworkConstantsUtil.cartDelete}/$customerId/$areaId';

    return await _apiService.get(
      endpoint,
      queryParams: {'cart_item_id': cartItemId},
      parser: (data) {
        if (data is Map<String, dynamic>) {
          return data;
        }
        return <String, dynamic>{};
      },
    );
  }

  /// Get cart count
  /// GET: cart/count/{customer_id}/{area_id}
  Future<ApiResult<int>> getCartCount() async {
    if (!_validateIds()) {
      return ApiResult.error(
        'Customer ID or Area ID not found. Please login and select area.',
      );
    }

    final endpoint = '${NetworkConstantsUtil.cartCount}/$customerId/$areaId';

    return await _apiService.get(
      endpoint,
      parser: (data) {
        // Handle different response formats
        if (data is int) {
          return data;
        } else if (data is Map<String, dynamic>) {
          // Try to extract count from various possible keys
          final count =
              data['count'] ?? data['cart_count'] ?? data['total'] ?? 0;
          return count is int ? count : int.tryParse(count.toString()) ?? 0;
        } else if (data is String) {
          return int.tryParse(data) ?? 0;
        }
        return 0;
      },
    );
  }

  /// Get full cart info
  /// GET: cart/info/{customer_id}/{area_id}
  Future<ApiResult<CartInfoModel>> getCartInfo() async {
    if (!_validateIds()) {
      return ApiResult.error(
        'Customer ID or Area ID not found. Please login and select area.',
      );
    }

    final endpoint = '${NetworkConstantsUtil.cartInfo}/$customerId/$areaId';

    return await _apiService.get(
      endpoint,
      parser: (data) {
        if (data is Map<String, dynamic>) {
          return CartInfoModel.fromJson(data);
        }
        throw Exception('Invalid cart data');
      },
    );
  }
}

/// Cart Info Response Model
class CartInfoModel {
  final List<CartItemModel> items;
  final double subtotal;
  final double shippingCharge;
  final double discount;
  final double total;
  final int itemCount;

  CartInfoModel({
    required this.items,
    required this.subtotal,
    required this.shippingCharge,
    this.discount = 0.0,
    required this.total,
    required this.itemCount,
  });

  factory CartInfoModel.fromJson(Map<String, dynamic> json) {
    // Parse cart items from response
    final itemsList = <CartItemModel>[];

    if (json['aCart'] != null) {
      // If aCart is a Map with numeric keys
      if (json['aCart'] is Map) {
        final cartMap = json['aCart'] as Map;
        cartMap.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            itemsList.add(CartItemModel.fromJson(value));
          }
        });
      }
      // If aCart is a List
      else if (json['aCart'] is List) {
        final cartList = json['aCart'] as List;
        itemsList.addAll(
          cartList.map((item) => CartItemModel.fromJson(item)),
        );
      }
    }

    // Parse totals - handle both string and numeric values
    final subtotal = _parseDouble(json['subtotal'] ?? json['sub_total'] ?? 0);
    final shippingCharge = _parseDouble(
      json['shipping_charge'] ??
          json['shippingCharge'] ??
          json['delivery_fee'] ??
          0,
    );
    final discount = _parseDouble(json['discount'] ?? 0);
    final total = _parseDouble(json['total'] ?? json['grand_total'] ?? 0);
    final itemCount =
        _parseInt(json['item_count'] ?? json['count'] ?? itemsList.length);

    return CartInfoModel(
      items: itemsList,
      subtotal: subtotal,
      shippingCharge: shippingCharge,
      discount: discount,
      total: total,
      itemCount: itemCount,
    );
  }

  /// Helper to parse double from various formats
  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Helper to parse int from various formats
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'shippingCharge': shippingCharge,
      'discount': discount,
      'total': total,
      'itemCount': itemCount,
    };
  }
}
