class CartItemModel {
  final String id;
  final String cartItemId; // cart_item_id from API
  final String productId;
  final String productName;
  final String productImage;
  final String selectedWeight;
  final String weightUnit;
  final int quantity;
  final double price;
  final double mrp;

  CartItemModel({
    required this.id,
    required this.cartItemId,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.selectedWeight,
    required this.quantity,
    required this.price,
    this.mrp = 0.0,
    this.weightUnit = '',
  });

  double get totalPrice => price * quantity;
  double get totalMrp => mrp * quantity;
  double get savings => totalMrp - totalPrice;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    // Handle both API response and local format
    final productId =
        (json['product_id'] ?? json['productId'] ?? '').toString();
    final cartItemId =
        (json['cart_item_id'] ?? json['id'] ?? productId).toString();

    String _parseString(dynamic v) => v == null ? '' : v.toString();

    return CartItemModel(
      id: cartItemId,
      cartItemId: cartItemId,
      productId: productId,
      productName: json['product_name'] ?? json['name'] ?? '',
      productImage:
          json['image_url'] ?? json['image'] ?? json['imageUrl'] ?? '',
      selectedWeight: _parseString(json['weight'] ??
          json['selectedWeight'] ??
          json['weight_value'] ??
          ''),
      weightUnit: _parseString(
          json['weight_unit'] ?? json['weightUnit'] ?? json['unit'] ?? ''),
      quantity: _parseInt(json['qty'] ?? json['quantity'] ?? 1),
      price:
          _parseDouble(json['price'] ?? json['amount'] ?? json['total'] ?? 0),
      mrp: _parseDouble(json['mrp'] ?? json['mrp_price'] ?? json['price'] ?? 0),
    );
  }

  /// Helper to parse int from various formats
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 1;
    return 1;
  }

  /// Helper to parse double from various formats
  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cart_item_id': cartItemId,
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'selectedWeight': selectedWeight,
      'weight_unit': weightUnit,
      'quantity': quantity,
      'price': price,
      'mrp': mrp,
    };
  }

  CartItemModel copyWith({
    String? id,
    String? cartItemId,
    String? productId,
    String? productName,
    String? productImage,
    String? selectedWeight,
    String? weightUnit,
    int? quantity,
    double? price,
    double? mrp,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      cartItemId: cartItemId ?? this.cartItemId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      selectedWeight: selectedWeight ?? this.selectedWeight,
      weightUnit: weightUnit ?? this.weightUnit,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      mrp: mrp ?? this.mrp,
    );
  }
}
