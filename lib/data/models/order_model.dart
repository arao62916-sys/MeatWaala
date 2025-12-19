import 'package:meatwaala_app/data/models/cart_item_model.dart';
import 'package:meatwaala_app/data/models/address_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<CartItemModel> items;
  final AddressModel deliveryAddress;
  final String deliveryTimeSlot;
  final String paymentMethod;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final String status;
  final DateTime createdAt;
  final DateTime? deliveredAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.deliveryAddress,
    required this.deliveryTimeSlot,
    required this.paymentMethod,
    required this.subtotal,
    this.deliveryFee = 0,
    this.discount = 0,
    required this.total,
    required this.status,
    required this.createdAt,
    this.deliveredAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      items: (json['items'] as List?)
              ?.map((item) => CartItemModel.fromJson(item))
              .toList() ??
          [],
      deliveryAddress: AddressModel.fromJson(json['deliveryAddress'] ?? {}),
      deliveryTimeSlot: json['deliveryTimeSlot'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'deliveryAddress': deliveryAddress.toJson(),
      'deliveryTimeSlot': deliveryTimeSlot,
      'paymentMethod': paymentMethod,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'total': total,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
    };
  }
}
