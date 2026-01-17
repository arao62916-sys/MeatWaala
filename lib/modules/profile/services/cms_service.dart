import 'dart:developer';
import 'package:meatwaala_app/core/network/base_api_service.dart';
import 'package:meatwaala_app/core/network/network_constents.dart';
import 'package:meatwaala_app/modules/profile/model/cms_model.dart';

/// Service for managing CMS content API calls
class CmsService {
  final BaseApiService _apiService = BaseApiService();

  static const String _logTag = '📄 CmsService';

  /// Fetch About Us content
  Future<CmsModel> fetchAboutUs() async {
    log('$_logTag Fetching About Us content');
    return _fetchCmsContent(NetworkConstantsUtil.cmsAboutUs);
  }

  /// Fetch Contact Us content
  Future<CmsModel> fetchContactUs() async {
    log('$_logTag Fetching Contact Us content');
    return _fetchCmsContent(NetworkConstantsUtil.cmsContactUs);
  }

  /// Fetch Privacy Policy content
  Future<CmsModel> fetchPrivacyPolicy() async {
    log('$_logTag Fetching Privacy Policy content');
    return _fetchCmsContent(NetworkConstantsUtil.cmsPrivacyPolicy);
  }

  /// Fetch Terms & Conditions content
  Future<CmsModel> fetchTerms() async {
    log('$_logTag Fetching Terms & Conditions content');
    return _fetchCmsContent(NetworkConstantsUtil.cmsTerms);
  }

  /// Generic method to fetch CMS content
  Future<CmsModel> _fetchCmsContent(String endpoint) async {
    try {
      final result = await _apiService.get<CmsModel>(
        endpoint,
        parser: (data) {
          // The API returns {status, message, aCms: {...}}
          // We need to extract the 'aCms' object
          if (data is Map<String, dynamic>) {
            final cmsData = data['aCms'];
            if (cmsData != null && cmsData is Map<String, dynamic>) {
              return CmsModel.fromJson(cmsData);
            }
            throw Exception('Invalid CMS data format');
          }
          throw Exception('Unexpected response format');
        },
      );

      if (result.success && result.data != null) {
        log('$_logTag ✅ Content fetched successfully');
        return result.data!;
      } else {
        final errorMsg = result.message.isNotEmpty
            ? result.message
            : 'Failed to fetch content';
        log('$_logTag ❌ $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      log('$_logTag ❌ Error: $e');
      throw Exception('Failed to load content. Please try again.');
    }
  }
}
