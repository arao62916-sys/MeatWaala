/// Order Item Model - Represents individual items in an order
class OrderItemModel {
  final String orderItemId;
  final String productId;
  final String productName;
  final String productImage;
  final String weight;
  final int quantity;
  final double price;
  final double mrp;
  final double total;
  final String status;
  final bool isReviewed;
  final String? reviewTitle;
  final String? reviewText;
  final int? rating;

  OrderItemModel({
    required this.orderItemId,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.weight,
    required this.quantity,
    required this.price,
    required this.mrp,
    required this.total,
    required this.status,
    this.isReviewed = false,
    this.reviewTitle,
    this.reviewText,
    this.rating,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      orderItemId: (json['order_item_id'] ?? json['id'] ?? '').toString(),
      productId: (json['product_id'] ?? '').toString(),
      productName: json['product_name'] ?? json['name'] ?? '',
      productImage: json['product_image'] ?? json['image'] ?? '',
      weight: json['weight'] ?? json['qty_weight'] ?? '',
      quantity: _parseInt(json['qty'] ?? json['quantity'] ?? 1),
      price: _parseDouble(json['price'] ?? 0),
      mrp: _parseDouble(json['mrp'] ?? json['price'] ?? 0),
      total: _parseDouble(json['total'] ?? json['item_total'] ?? 0),
      status: json['status'] ?? '',
      isReviewed: json['is_reviewed'] == 1 ||
          json['is_reviewed'] == '1' ||
          json['is_reviewed'] == true,
      reviewTitle: json['review_title'],
      reviewText: json['review'],
      rating: json['rating'] != null ? _parseInt(json['rating']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_item_id': orderItemId,
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'weight': weight,
      'quantity': quantity,
      'price': price,
      'mrp': mrp,
      'total': total,
      'status': status,
      'is_reviewed': isReviewed ? 1 : 0,
      'review_title': reviewTitle,
      'review': reviewText,
      'rating': rating,
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

/// Order Status Timeline Entry
class OrderStatusModel {
  final String status;
  final String statusLabel;
  final String timestamp;
  final String? remarks;
  final bool isActive;

  OrderStatusModel({
    required this.status,
    required this.statusLabel,
    required this.timestamp,
    this.remarks,
    this.isActive = false,
  });

  factory OrderStatusModel.fromJson(Map<String, dynamic> json) {
    return OrderStatusModel(
      status: json['status'] ?? '',
      statusLabel: json['status_label'] ?? json['label'] ?? '',
      timestamp: json['timestamp'] ?? json['created_at'] ?? '',
      remarks: json['remarks'] ?? json['notes'],
      isActive: json['is_active'] == 1 ||
          json['is_active'] == '1' ||
          json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'status_label': statusLabel,
      'timestamp': timestamp,
      'remarks': remarks,
      'is_active': isActive ? 1 : 0,
    };
  }
}

/// Complete Order Detail Model
class OrderDetailModel {
  final String orderId;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final String customerMobile;
  final String customerEmail;
  final List<OrderItemModel> items;
  final double subtotal;
  final double shippingCharge;
  final double discount;
  final double total;
  final String orderStatus;
  final String paymentStatus;
  final String paymentId;
  final String paymentMethod;
  final String addressLine1;
  final String addressLine2;
  final String? addressLine3;
  final String areaId;
  final String areaName;
  final String? pincode;
  final String? remarks;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final List<OrderStatusModel> statusTimeline;

  OrderDetailModel({
    required this.orderId,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.customerMobile,
    required this.customerEmail,
    required this.items,
    required this.subtotal,
    required this.shippingCharge,
    this.discount = 0.0,
    required this.total,
    required this.orderStatus,
    required this.paymentStatus,
    required this.paymentId,
    required this.paymentMethod,
    required this.addressLine1,
    required this.addressLine2,
    this.addressLine3,
    required this.areaId,
    required this.areaName,
    this.pincode,
    this.remarks,
    required this.createdAt,
    this.deliveredAt,
    this.statusTimeline = const [],
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    // Parse order items
    final itemsList = <OrderItemModel>[];
    if (json['aOrderItem'] != null) {
      if (json['aOrderItem'] is Map) {
        final itemsMap = json['aOrderItem'] as Map;
        itemsMap.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            itemsList.add(OrderItemModel.fromJson(value));
          }
        });
      } else if (json['aOrderItem'] is List) {
        final items = json['aOrderItem'] as List;
        itemsList.addAll(
          items.map((item) => OrderItemModel.fromJson(item)),
        );
      }
    }

    // Parse status timeline
    final statusList = <OrderStatusModel>[];
    if (json['aStatus'] != null) {
      if (json['aStatus'] is Map) {
        final statusMap = json['aStatus'] as Map;
        statusMap.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            statusList.add(OrderStatusModel.fromJson(value));
          }
        });
      } else if (json['aStatus'] is List) {
        final statuses = json['aStatus'] as List;
        statusList.addAll(
          statuses.map((status) => OrderStatusModel.fromJson(status)),
        );
      }
    }

    return OrderDetailModel(
      orderId: (json['order_id'] ?? json['id'] ?? '').toString(),
      orderNumber: json['order_number'] ?? json['order_no'] ?? '',
      customerId: (json['customer_id'] ?? '').toString(),
      customerName: json['name'] ?? json['customer_name'] ?? '',
      customerMobile: json['mobile'] ?? json['customer_mobile'] ?? '',
      customerEmail: json['email_id'] ?? json['customer_email'] ?? '',
      items: itemsList,
      subtotal: _parseDouble(json['subtotal'] ?? json['sub_total'] ?? 0),
      shippingCharge: _parseDouble(
        json['shipping_charge'] ?? json['delivery_charge'] ?? 0,
      ),
      discount: _parseDouble(json['discount'] ?? 0),
      total: _parseDouble(json['total'] ?? json['grand_total'] ?? 0),
      orderStatus: json['order_status'] ?? json['status'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      paymentId: json['payment_id'] ?? json['transaction_id'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      addressLine1: json['address_line1'] ?? json['address'] ?? '',
      addressLine2: json['address_line2'] ?? '',
      addressLine3: json['address_line3'],
      areaId: (json['area_id'] ?? '').toString(),
      areaName: json['area_name'] ?? '',
      pincode: json['pincode'] ?? json['pin_code'],
      remarks: json['remarks'] ?? json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      deliveredAt: json['delivered_at'] != null
          ? DateTime.tryParse(json['delivered_at'])
          : null,
      statusTimeline: statusList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'order_number': orderNumber,
      'customer_id': customerId,
      'name': customerName,
      'mobile': customerMobile,
      'email_id': customerEmail,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'shipping_charge': shippingCharge,
      'discount': discount,
      'total': total,
      'order_status': orderStatus,
      'payment_status': paymentStatus,
      'payment_id': paymentId,
      'payment_method': paymentMethod,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'address_line3': addressLine3,
      'area_id': areaId,
      'area_name': areaName,
      'pincode': pincode,
      'remarks': remarks,
      'created_at': createdAt.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'status_timeline': statusTimeline.map((s) => s.toJson()).toList(),
    };
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  bool get isDelivered => orderStatus.toLowerCase() == 'delivered';
  bool get canReview => isDelivered;
}

/// Order Summary Model for List View
class OrderSummaryModel {
  final String orderId;
  final String orderNumber;
  final double total;
  final String orderStatus;
  final String paymentStatus;
  final DateTime createdAt;
  final int itemCount;

  OrderSummaryModel({
    required this.orderId,
    required this.orderNumber,
    required this.total,
    required this.orderStatus,
    required this.paymentStatus,
    required this.createdAt,
    this.itemCount = 0,
  });

  factory OrderSummaryModel.fromJson(Map<String, dynamic> json) {
    return OrderSummaryModel(
      orderId: (json['order_id'] ?? json['id'] ?? '').toString(),
      orderNumber: json['order_number'] ?? json['order_no'] ?? '',
      total: _parseDouble(json['total'] ?? json['grand_total'] ?? 0),
      orderStatus: json['order_status'] ?? json['status'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      itemCount: _parseInt(json['item_count'] ?? json['total_items'] ?? 0),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
