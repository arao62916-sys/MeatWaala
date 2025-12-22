import 'dart:developer';
import 'package:get/get.dart';
import 'package:meatwaala_app/data/models/company_model.dart';
import 'package:meatwaala_app/data/services/company_api_service.dart';
import 'package:meatwaala_app/services/storage_service.dart';

/// Controller for managing company data
/// Should be initialized at app startup and kept alive throughout the app
class CompanyController extends GetxController {
  final CompanyApiService _apiService = CompanyApiService();
  final StorageService _storage = StorageService();

  // Observable states
  final Rx<CompanyModel?> company = Rx<CompanyModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;

  // Getters for easy access
  String get logoUrl => company.value?.logoUrl ?? '';
  String get displayName => company.value?.displayName ?? 'MeatWaala';
  String get loginBg => company.value?.loginBg ?? '';
  String get loginIcon => company.value?.loginIcon ?? '';
  String get phone => company.value?.phone ?? '';
  String get email => company.value?.emailId ?? '';

  @override
  void onInit() {
    super.onInit();
    // Try to load from storage first
    _loadFromStorage();
  }

  /// Load company data from local storage
  void _loadFromStorage() {
    final storedData = _storage.getCompanyData();
    if (storedData != null) {
      company.value = CompanyModel.fromJson(storedData);
      log('📦 Company data loaded from storage: ${company.value?.displayName}');
    }
  }

  /// Fetch company details from API
  /// This should be called on app launch
  Future<bool> fetchCompanyDetails() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final result = await _apiService.getCompanyDetails();

      if (result.success && result.data != null) {
        company.value = result.data;
        // Save to local storage
        await _storage.saveCompanyData(result.data!.toJson());
        log('✅ Company data fetched and saved: ${company.value?.displayName}');
        isLoading.value = false;
        return true;
      } else {
        hasError.value = true;
        errorMessage.value = result.message;
        log('❌ Failed to fetch company: ${result.message}');
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load company data';
      log('❌ Error fetching company: $e');
      isLoading.value = false;
      return false;
    }
  }

  /// Check if company data is available (either from storage or API)
  bool get hasCompanyData => company.value != null;
}
