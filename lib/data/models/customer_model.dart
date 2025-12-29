/// Customer Model for user/customer data from API
class CustomerModel {
  final String customerId;
  final String name;
  final String emailId;
  final String mobile;
  final String areaId;
  final String areaName;
  final String address;
  final String city;
  final String state;
  final String pin;
  final String profileImage;
  final String status;
  final String createdAt;

  CustomerModel({
    required this.customerId,
    required this.name,
    required this.emailId,
    required this.mobile,
    required this.areaId,
    required this.areaName,
    required this.address,
    required this.city,
    required this.state,
    required this.pin,
    required this.profileImage,
    required this.status,
    required this.createdAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    // Build address from multiple fields if available
    String fullAddress = '';
    if (json['address_line1'] != null &&
        json['address_line1'].toString().isNotEmpty) {
      fullAddress = json['address_line1'].toString();
      if (json['address_line2'] != null &&
          json['address_line2'].toString().isNotEmpty) {
        fullAddress += ', ${json['address_line2']}';
      }
    } else {
      fullAddress = json['address'] ?? '';
    }

    return CustomerModel(
      customerId:
          json['customer_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      emailId: json['email_id'] ?? json['email'] ?? '',
      mobile: json['mobile'] ?? json['phone'] ?? '',
      areaId: json['area_id']?.toString() ?? '',
      areaName: json['area_name'] ?? json['area'] ?? '',
      address: fullAddress,
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pin: json['pin']?.toString() ?? '',
      profileImage:
          json['profile_image'] ?? json['image'] ?? json['profile_url'] ?? '',
      status: json['status']?.toString() ?? '1',
      createdAt: json['created_at'] ?? json['createdAt'] ?? json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'name': name,
      'email_id': emailId,
      'mobile': mobile,
      'area_id': areaId,
      'area_name': areaName,
      'address': address,
      'city': city,
      'state': state,
      'pin': pin,
      'profile_image': profileImage,
      'status': status,
      'created_at': createdAt,
    };
  }

  /// Check if user is active
  bool get isActive =>
      status.toLowerCase() == 'enabled' ||
      status == '1' ||
      status.toLowerCase() == 'active';

  /// Check if user has complete profile
  bool get hasCompleteProfile =>
      name.isNotEmpty && emailId.isNotEmpty && mobile.isNotEmpty;

  @override
  String toString() {
    return 'CustomerModel(customerId: $customerId, name: $name, email: $emailId)';
  }

  CustomerModel copyWith({
    String? customerId,
    String? name,
    String? emailId,
    String? mobile,
    String? areaId,
    String? areaName,
    String? address,
    String? city,
    String? state,
    String? pin,
    String? profileImage,
    String? status,
    String? createdAt,
  }) {
    return CustomerModel(
      customerId: customerId ?? this.customerId,
      name: name ?? this.name,
      emailId: emailId ?? this.emailId,
      mobile: mobile ?? this.mobile,
      areaId: areaId ?? this.areaId,
      areaName: areaName ?? this.areaName,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pin: pin ?? this.pin,
      profileImage: profileImage ?? this.profileImage,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
