import 'dart:developer';
import 'package:meatwaala_app/core/network/base_api_service.dart';
import 'package:meatwaala_app/core/network/network_constents.dart';

import 'package:meatwaala_app/modules/profile/model/user_model.dart';

class ProfileService {
  final BaseApiService _apiService = BaseApiService();

  /// Fetch customer profile
  Future<CustomerProfileModel?> fetchProfile(String customerId) async {
    try {
      final endpoint = '${NetworkConstantsUtil.userProfile}/$customerId';
      
      log('👤 ProfileService: Fetching profile for customer: $customerId');

      final result = await _apiService.get<CustomerProfileModel>(
        endpoint,
        parser: (data) =>
            CustomerProfileModel.fromJson(data as Map<String, dynamic>),
      );

      if (result.success && result.data != null) {
        log('✅ ProfileService: Profile fetched successfully');
        return result.data;
      } else {
        log('❌ ProfileService: Profile fetch failed: ${result.message}');
        throw Exception(result.message);
      }
    } catch (e) {
      log('❌ ProfileService: Error fetching profile: $e');
      rethrow;
    }
  }

  /// Update customer profile
  Future<String> updateProfile(
    String customerId,
    Map<String, String> formData,
  ) async {
    try {
      final endpoint = '${NetworkConstantsUtil.updateProfile}/$customerId';
      
      log('📝 ProfileService: Updating profile for customer: $customerId');
      log('📝 ProfileService: Form data: $formData');

      final result = await _apiService.postFormData<Map<String, dynamic>>(
        endpoint,
        fields: formData,
      );

      if (result.success) {
        log('✅ ProfileService: Profile updated successfully');
        return result.message.isNotEmpty
            ? result.message
            : 'Profile updated successfully';
      } else {
        log('❌ ProfileService: Profile update failed: ${result.message}');
        throw Exception(result.message);
      }
    } catch (e) {
      log('❌ ProfileService: Error updating profile: $e');
      rethrow;
    }
  }

  /// Change customer password
  Future<String> changePassword(
    String customerId,
    Map<String, String> passwordData,
  ) async {
    try {
      final endpoint = '${NetworkConstantsUtil.changePassword}/$customerId';
      
      log('🔑 ProfileService: Changing password for customer: $customerId');

      final result = await _apiService.postFormData<Map<String, dynamic>>(
        endpoint,
        fields: passwordData,
      );

      if (result.success) {
        log('✅ ProfileService: Password changed successfully');
        return result.message.isNotEmpty
            ? result.message
            : 'Password changed successfully';
      } else {
        log('❌ ProfileService: Password change failed: ${result.message}');
        throw Exception(result.message);
      }
    } catch (e) {
      log('❌ ProfileService: Error changing password: $e');
      rethrow;
    }
  }
}