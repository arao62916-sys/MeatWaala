/// Customer Profile Model for Profile API Response
class CustomerProfileModel {
  final String customerId;
  final String name;
  final String emailId;
  final String mobile;
  final String areaId;
  final String addressLine1;
  final String addressLine2;
  final String landmark;
  final String pincode;
  final String city;
  final String state;
  final String country;
  final String profileImage;
  final String status;
  final String createdAt;
  final String updatedAt;

  CustomerProfileModel({
    required this.customerId,
    required this.name,
    required this.emailId,
    required this.mobile,
    required this.areaId,
    required this.addressLine1,
    required this.addressLine2,
    required this.landmark,
    required this.pincode,
    required this.city,
    required this.state,
    required this.country,
    required this.profileImage,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerProfileModel.fromJson(Map<String, dynamic> json) {
    return CustomerProfileModel(
      customerId: json['customer_id']?.toString() ?? '',
      name: json['name'] ?? '',
      emailId: json['email_id'] ?? '',
      mobile: json['mobile'] ?? '',
      areaId: json['area_id']?.toString() ?? '',
      addressLine1: json['address_line1'] ?? '',
      addressLine2: json['address_line2'] ?? '',
      landmark: json['landmark'] ?? '',
      pincode: json['pincode']?.toString() ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      profileImage: json['profile_image'] ?? '',
      status: json['status']?.toString() ?? '1',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'name': name,
      'email_id': emailId,
      'mobile': mobile,
      'area_id': areaId,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'landmark': landmark,
      'pincode': pincode,
      'city': city,
      'state': state,
      'country': country,
      'profile_image': profileImage,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Create a copy with updated fields
  CustomerProfileModel copyWith({
    String? customerId,
    String? name,
    String? emailId,
    String? mobile,
    String? areaId,
    String? addressLine1,
    String? addressLine2,
    String? landmark,
    String? pincode,
    String? city,
    String? state,
    String? country,
    String? profileImage,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return CustomerProfileModel(
      customerId: customerId ?? this.customerId,
      name: name ?? this.name,
      emailId: emailId ?? this.emailId,
      mobile: mobile ?? this.mobile,
      areaId: areaId ?? this.areaId,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      landmark: landmark ?? this.landmark,
      pincode: pincode ?? this.pincode,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      profileImage: profileImage ?? this.profileImage,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if profile is active
  bool get isActive => status == '1';

  /// Get full address
  String get fullAddress {
    final parts = <String>[];
    if (addressLine1.isNotEmpty) parts.add(addressLine1);
    if (addressLine2.isNotEmpty) parts.add(addressLine2);
    if (landmark.isNotEmpty) parts.add(landmark);
    if (city.isNotEmpty) parts.add(city);
    if (state.isNotEmpty) parts.add(state);
    if (pincode.isNotEmpty) parts.add(pincode);
    return parts.join(', ');
  }

  /// Get short address (first line only)
  String get shortAddress {
    final parts = <String>[];
    if (addressLine1.isNotEmpty) parts.add(addressLine1);
    if (city.isNotEmpty) parts.add(city);
    return parts.join(', ');
  }

  /// Get user initials for avatar
  String get initials {
    if (name.isEmpty) return 'U';
    final names = name.split(' ');
    if (names.length > 1) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  String toString() {
    return 'CustomerProfileModel(name: $name, email: $emailId, mobile: $mobile)';
  }
}