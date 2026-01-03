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
    print('Updating cart: productId=$productId, quantity=$quantity');
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
    print("Removing cart item:==>✅✅ $cartItemId");
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
  final String? coupon;
  final String? areaId;
  final Map<String, dynamic>? areaInfo;

  CartInfoModel({
    required this.items,
    required this.subtotal,
    required this.shippingCharge,
    this.discount = 0.0,
    required this.total,
    required this.itemCount,
    this.coupon,
    this.areaId,
    this.areaInfo,
  });

  factory CartInfoModel.fromJson(Map<String, dynamic> json) {
    // Extract aCart object
    final aCart = json['aCart'] as Map<String, dynamic>? ?? {};
    
    // Parse cart items from aItem array
    final itemsList = <CartItemModel>[];
    if (aCart['aItem'] != null && aCart['aItem'] is List) {
      final cartList = aCart['aItem'] as List;
      itemsList.addAll(
        cartList.map((item) => CartItemModel.fromJson(item)),
      );
    }

    // Parse totals from aCart object
    final billAmount = _parseDouble(aCart['bill_amount'] ?? 0);
    final shippingCharge = _parseDouble(aCart['shipping_charge'] ?? 0);
    final discount = _parseDouble(aCart['discount'] ?? 0);
    final discountedAmount = _parseDouble(aCart['discounted_amount'] ?? 0);
    final total = _parseDouble(aCart['amount'] ?? 0);
    final itemCount = _parseInt(aCart['items'] ?? aCart['qty'] ?? itemsList.length);

    return CartInfoModel(
      items: itemsList,
      subtotal: billAmount,
      shippingCharge: shippingCharge,
      discount: discount,
      total: total,
      itemCount: itemCount,
      coupon: aCart['coupon']?.toString(),
      areaId: aCart['area_id']?.toString(),
      areaInfo: aCart['aArea'] as Map<String, dynamic>?,
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
      'coupon': coupon,
      'areaId': areaId,
      'areaInfo': areaInfo,
    };
  }
}