// /// Customer Profile Model for Profile API Response
// class CustomerProfileModel {
//   final String customerId;
//   final String name;
//   final String emailId;
//   final String mobile;
//   final String areaId;
//   final String addressLine1;
//   final String addressLine2;
//   final String landmark;
//   final String pincode;
//   final String city;
//   final String state;
//   final String country;
//   final String profileImage;
//   final String status;
//   final String createdAt;
//   final String updatedAt;

//   CustomerProfileModel({
//     required this.customerId,
//     required this.name,
//     required this.emailId,
//     required this.mobile,
//     required this.areaId,
//     required this.addressLine1,
//     required this.addressLine2,
//     required this.landmark,
//     required this.pincode,
//     required this.city,
//     required this.state,
//     required this.country,
//     required this.profileImage,
//     required this.status,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory CustomerProfileModel.fromJson(Map<String, dynamic> json) {
//     return CustomerProfileModel(
//       customerId: json['customer_id']?.toString() ?? '',
//       name: json['name'] ?? '',
//       emailId: json['email_id'] ?? '',
//       mobile: json['mobile'] ?? '',
//       areaId: json['area_id']?.toString() ?? '',
//       addressLine1: json['address_line1'] ?? '',
//       addressLine2: json['address_line2'] ?? '',
//       landmark: json['landmark'] ?? '',
//       pincode: json['pincode']?.toString() ?? '',
//       city: json['city'] ?? '',
//       state: json['state'] ?? '',
//       country: json['country'] ?? '',
//       profileImage: json['profile_image'] ?? '',
//       status: json['status']?.toString() ?? '1',
//       createdAt: json['created_at'] ?? '',
//       updatedAt: json['updated_at'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'customer_id': customerId,
//       'name': name,
//       'email_id': emailId,
//       'mobile': mobile,
//       'area_id': areaId,
//       'address_line1': addressLine1,
//       'address_line2': addressLine2,
//       'landmark': landmark,
//       'pincode': pincode,
//       'city': city,
//       'state': state,
//       'country': country,
//       'profile_image': profileImage,
//       'status': status,
//       'created_at': createdAt,
//       'updated_at': updatedAt,
//     };
//   }

//   /// Check if profile is active
//   bool get isActive => status == '1';

//   /// Get full address
//   String get fullAddress {
//     final parts = <String>[];
//     if (addressLine1.isNotEmpty) parts.add(addressLine1);
//     if (addressLine2.isNotEmpty) parts.add(addressLine2);
//     if (landmark.isNotEmpty) parts.add(landmark);
//     if (city.isNotEmpty) parts.add(city);
//     if (state.isNotEmpty) parts.add(state);
//     if (pincode.isNotEmpty) parts.add(pincode);
//     return parts.join(', ');
//   }
// }
