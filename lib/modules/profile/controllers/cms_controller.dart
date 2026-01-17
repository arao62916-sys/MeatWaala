import 'dart:developer';
import 'package:get/get.dart';
import 'package:meatwaala_app/modules/profile/model/cms_model.dart';
import 'package:meatwaala_app/modules/profile/services/cms_service.dart';

/// Controller for managing CMS content (About Us, Contact Us, Privacy Policy, Terms)
class CmsController extends GetxController {
  final CmsService _cmsService = CmsService();

  // ========== Observable States ==========
  final isLoading = false.obs;
  final Rx<CmsModel?> cmsContent = Rx<CmsModel?>(null);
  final RxString errorMessage = ''.obs;

  static const String _logTag = '📄 CmsController';

  /// Fetch About Us content
  Future<void> fetchAboutUs() async {
    await _fetchContent(
      fetcher: _cmsService.fetchAboutUs,
      contentType: 'About Us',
    );
  }

  /// Fetch Contact Us content
  Future<void> fetchContactUs() async {
    await _fetchContent(
      fetcher: _cmsService.fetchContactUs,
      contentType: 'Contact Us',
    );
  }

  /// Fetch Privacy Policy content
  Future<void> fetchPrivacyPolicy() async {
    await _fetchContent(
      fetcher: _cmsService.fetchPrivacyPolicy,
      contentType: 'Privacy Policy',
    );
  }

  /// Fetch Terms & Conditions content
  Future<void> fetchTerms() async {
    await _fetchContent(
      fetcher: _cmsService.fetchTerms,
      contentType: 'Terms & Conditions',
    );
  }

  /// Generic method to fetch CMS content
  Future<void> _fetchContent({
    required Future<CmsModel> Function() fetcher,
    required String contentType,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      cmsContent.value = null;

      log('$_logTag Fetching $contentType');

      final content = await fetcher();
      cmsContent.value = content;

      log('$_logTag ✅ $contentType loaded successfully');
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      log('$_logTag ❌ Error loading $contentType: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear content when navigating away
  void clearContent() {
    cmsContent.value = null;
    errorMessage.value = '';
  }

  @override
  void onClose() {
    clearContent();
    super.onClose();
  }
}
