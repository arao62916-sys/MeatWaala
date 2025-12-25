import 'package:meatwaala_app/core/network/base_api_service.dart';
import 'package:meatwaala_app/core/network/network_constents.dart';
import 'package:meatwaala_app/data/models/customer_model.dart';

/// Response model for Signup API
class SignupResponse {
  final int status;
  final String message;
  final String customerId;
  final CustomerModel? customer;

  SignupResponse({
    required this.status,
    required this.message,
    required this.customerId,
    this.customer,
  });

  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    CustomerModel? customer;
    if (json['aCustomer'] != null) {
      customer =
          CustomerModel.fromJson(json['aCustomer'] as Map<String, dynamic>);
    }
    return SignupResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      customer: customer,
    );
  }
}

/// Response model for Login API
class LoginResponse {
  final int status;
  final String message;
  final String customerId;
  final CustomerModel? customer;

  LoginResponse({
    required this.status,
    required this.message,
    required this.customerId,
    this.customer,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    CustomerModel? customer;
    if (json['aCustomer'] != null) {
      customer =
          CustomerModel.fromJson(json['aCustomer'] as Map<String, dynamic>);
    }
    return LoginResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      customer: customer,
    );
  }
}

/// Response model for Forgot Password API
class ForgotPasswordResponse {
  final int status;
  final String message;
  final String customerId;
  final CustomerModel? customer;

  ForgotPasswordResponse({
    required this.status,
    required this.message,
    required this.customerId,
    this.customer,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    CustomerModel? customer;
    if (json['aCustomer'] != null) {
      customer =
          CustomerModel.fromJson(json['aCustomer'] as Map<String, dynamic>);
    }

    return ForgotPasswordResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      customer: customer,
    );
  }
}

/// API Service for Authentication (Signup, Login, Logout)
class AuthApiService extends BaseApiService {
  /// Signup a new user
  /// Uses multipart/form-data
  /// Fields: name, email_id, mobile, area_id
  /// On success, password is sent to user's email
  Future<ApiResult<SignupResponse>> signup({
    required String name,
    required String emailId,
    required String mobile,
    required String areaId,
  }) async {
    return postMultipart<SignupResponse>(
      NetworkConstantsUtil.signup,
      fields: {
        'name': name,
        'email_id': emailId,
        'mobile': mobile,
        'area_id': areaId,
      },
      parser: (data) {
        // The full response includes status, message, customer_id, aCustomer
        // We need to parse from the raw response
        if (data is Map<String, dynamic>) {
          return SignupResponse.fromJson(data);
        }
        return SignupResponse(
          status: 0,
          message: 'Invalid response',
          customerId: '',
        );
      },
    );
  }

  /// Login with email and password
  Future<ApiResult<LoginResponse>> login({
    required String emailId,
    required String password,
  }) async {
    return postMultipart<LoginResponse>(
      NetworkConstantsUtil.login,
      fields: {
        'email_id': emailId,
        'password': password,
      },
      parser: (data) {
        if (data is Map<String, dynamic>) {
          return LoginResponse.fromJson(data);
        }
        return LoginResponse(
          status: 0,
          message: 'Invalid response',
          customerId: '',
        );
      },
    );
  }

/// Forgot Password
Future<ApiResult<ForgotPasswordResponse>> forgotPassword({
  required String emailId,
  required String mobile,
}) async {
  return postMultipart<ForgotPasswordResponse>(
    NetworkConstantsUtil.forgot_password,
    fields: {
      'email_id': emailId,
      'mobile': mobile,
    },
    parser: (data) {
      if (data is Map<String, dynamic>) {
        return ForgotPasswordResponse.fromJson(data);
      }
      return ForgotPasswordResponse(
        status: 0,
        message: 'Invalid response',
        customerId: '',
      );
    },
  );
}

  /// Logout user
  Future<ApiResult<Map<String, dynamic>>> logout() async {
    return post<Map<String, dynamic>>(
      NetworkConstantsUtil.logout,
    );
  }
}
