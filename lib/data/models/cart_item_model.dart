import 'package:meatwaala_app/data/models/product_model.dart';

class CartItemModel {
  final String id;
  final ProductModel product;
  final String selectedWeight;
  final int quantity;
  final double price;

  CartItemModel({
    required this.id,
    required this.product,
    required this.selectedWeight,
    required this.quantity,
    required this.price,
  });

  double get totalPrice => price * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] ?? '',
      product: ProductModel.fromJson(json['product']),
      selectedWeight: json['selectedWeight'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'selectedWeight': selectedWeight,
      'quantity': quantity,
      'price': price,
    };
  }

  CartItemModel copyWith({
    String? id,
    ProductModel? product,
    String? selectedWeight,
    int? quantity,
    double? price,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      product: product ?? this.product,
      selectedWeight: selectedWeight ?? this.selectedWeight,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }
}
