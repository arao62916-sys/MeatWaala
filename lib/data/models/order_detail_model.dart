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
  // 🔑 Handle wrapped response
  final orderJson = json['aOrder'] ?? json;

  // Parse order items (aItem)
  final itemsList = <OrderItemModel>[];
  if (orderJson['aItem'] != null && orderJson['aItem'] is List) {
    itemsList.addAll(
      (orderJson['aItem'] as List)
          .map((item) => OrderItemModel.fromJson(item)),
    );
  }

  // Parse status timeline (aStatus is outside aOrder)
  final statusList = <OrderStatusModel>[];
  if (json['aStatus'] != null && json['aStatus'] is List) {
    statusList.addAll(
      (json['aStatus'] as List)
          .map((status) => OrderStatusModel.fromJson(status)),
    );
  }

  return OrderDetailModel(
    orderId: (orderJson['order_id'] ?? '').toString(),
    orderNumber: orderJson['no'] ?? '',
    customerId: (orderJson['customer_id'] ?? '').toString(),
    customerName: orderJson['name'] ?? '',
    customerMobile: orderJson['mobile'] ?? '',
    customerEmail: orderJson['email_id'] ?? '',
    items: itemsList,
    subtotal: _parseDouble(
      orderJson['discounted_amount'] ?? orderJson['amount'] ?? 0,
    ),
    shippingCharge: _parseDouble(orderJson['shipping_charge'] ?? 0),
    discount: _parseDouble(orderJson['discount'] ?? 0),
    total: _parseDouble(orderJson['bill_amount'] ?? 0),
    orderStatus: orderJson['order_status'] ?? '',
    paymentStatus: orderJson['payment_status'] ?? '',
    paymentId: orderJson['payment_id'] ?? '',
    paymentMethod: orderJson['mode'] ?? '',
    addressLine1: orderJson['address_line1'] ?? '',
    addressLine2: orderJson['address_line2'] ?? '',
    areaId: (orderJson['area_id'] ?? '').toString(),
    areaName: orderJson['area'] ?? '',
    remarks: orderJson['remarks'],
    createdAt: DateTime.tryParse(orderJson['date'] ?? '') ?? DateTime.now(),
    deliveredAt: null, // not provided in response
    statusTimeline: statusList,
  );
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
  final String customerName;
  final String mobile;
  final String addressLine1;
  final String addressLine2;
  final String area;

  OrderSummaryModel({
    required this.orderId,
    required this.orderNumber,
    required this.total,
    required this.orderStatus,
    required this.paymentStatus,
    required this.createdAt,
    this.itemCount = 0,
    required this.customerName,
    required this.mobile,
    required this.addressLine1,
    required this.addressLine2,
    required this.area,
  });

  factory OrderSummaryModel.fromJson(Map<String, dynamic> json) {
    return OrderSummaryModel(
      orderId: (json['order_id'] ?? '').toString(),
      orderNumber: json['no'] ?? '',
      total: _parseDouble(json['bill_amount'] ?? 0),
      orderStatus: json['order_status'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      createdAt: json['date'] != null
          ? DateTime.tryParse(json['date']) ?? DateTime.now()
          : DateTime.now(),
      itemCount: _parseInt(json['item_count'] ?? 0),
      customerName: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      addressLine1: json['address_line1'] ?? '',
      addressLine2: json['address_line2'] ?? '',
      area: json['area'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'no': orderNumber,
      'bill_amount': total,
      'order_status': orderStatus,
      'payment_status': paymentStatus,
      'date': createdAt.toIso8601String(),
      'item_count': itemCount,
      'name': customerName,
      'mobile': mobile,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'area': area,
    };
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
