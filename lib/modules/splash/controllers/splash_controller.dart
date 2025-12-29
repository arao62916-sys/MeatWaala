import 'dart:developer';
import 'package:get/get.dart';
import 'package:meatwaala_app/core/constants/app_constants.dart';
import 'package:meatwaala_app/data/models/company_model.dart';
import 'package:meatwaala_app/data/services/company_api_service.dart';
import 'package:meatwaala_app/routes/app_routes.dart';
import 'package:meatwaala_app/services/storage_service.dart';

class SplashController extends GetxController {
  final StorageService _storage = StorageService();
  final CompanyApiService _companyApiService = CompanyApiService();

  // Observable states
  final Rx<CompanyModel?> company = Rx<CompanyModel?>(null);
  final RxBool isLoadingCompany = true.obs;
  final RxBool hasCompanyError = false.obs;

  // Getters for UI
  String get logoUrl => company.value?.logoUrl ?? '';
  String get displayName => company.value?.displayName ?? AppConstants.appName;

  @override
  void onInit() {
    super.onInit();
    log("✅ SplashController onInit called");
    _initializeApp();
  }

  /// Initialize app - fetch company data first, then navigate
  Future<void> _initializeApp() async {
    // CRITICAL: Ensure storage is fully initialized before reading
    await Future.delayed(const Duration(milliseconds: 100));

    // Load company data from storage first (for instant display)
    _loadCompanyFromStorage();

    // Fetch fresh company data from API
    await _fetchCompanyData();

    // Wait for minimum splash duration
    await Future.delayed(const Duration(seconds: AppConstants.splashDuration));

    // Navigate to next screen
    _navigateToNext();
  }

  /// Load company data from local storage
  void _loadCompanyFromStorage() {
    final storedData = _storage.getCompanyData();
    if (storedData != null) {
      company.value = CompanyModel.fromJson(storedData);
      log('📦 Company loaded from storage: ${company.value?.displayName}');
    }
  }

  /// Fetch company data from API
  Future<void> _fetchCompanyData() async {
    isLoadingCompany.value = true;
    hasCompanyError.value = false;

    try {
      final result = await _companyApiService.getCompanyDetails();

      if (result.success && result.data != null) {
        company.value = result.data;
        // Save to storage for next app launch
        await _storage.saveCompanyData(result.data!.toJson());
        log('✅ Company data fetched: ${company.value?.displayName}');
      } else {
        log('⚠️ Company API failed: ${result.message}');
        hasCompanyError.value = company.value == null;
      }
    } catch (e) {
      log('❌ Error fetching company data: $e');
      hasCompanyError.value = company.value == null;
    } finally {
      isLoadingCompany.value = false;
    }
  }

  /// Navigate to next screen based on app state
  void _navigateToNext() {
    final isFirstTime = _storage.isFirstTime();

    if (isFirstTime) {
      log('👋 First time user - navigating to onboarding');
      Get.offAllNamed(AppRoutes.onboarding);
      return;
    }

    final isLoggedIn = _storage.isLoggedIn();
    final hasSelectedArea = _storage.hasSelectedArea();
    final token = _storage.getToken();
    final userId = _storage.getUserId();

    // Comprehensive debug logging
    log('🔍 ========== NAVIGATION CHECK ==========');
    log('   - isLoggedIn(): $isLoggedIn');
    log('   - hasSelectedArea: $hasSelectedArea');
    log('   - token exists: ${token != null && token.isNotEmpty}');
    log('   - token value: $token');
    log('   - userId: $userId');
    log('   - userName: ${_storage.getUserName()}');
    log('   - userEmail: ${_storage.getUserEmail()}');
    _storage.debugPrintStorage();
    log('🔍 ====================================');

    if (isLoggedIn) {
      log('👤 User logged in - navigating to main');
      Get.offAllNamed(AppRoutes.main);
    } else if (hasSelectedArea) {
      log('📍 Area selected but not logged in - navigating to login');
      Get.offAllNamed(AppRoutes.login);
    } else {
      log('🗺️ No area selected - navigating to location');
      Get.offAllNamed(AppRoutes.location);
    }
  }
}
