import 'dart:developer';
import 'package:get/get.dart';
import 'package:meatwaala_app/data/models/area_model.dart';
import 'package:meatwaala_app/data/services/area_api_service.dart';
import 'package:meatwaala_app/services/storage_service.dart';

/// Controller for managing area selection
class AreaController extends GetxController {
  final AreaApiService _apiService = AreaApiService();
  final StorageService _storage = StorageService();

  // Observable states
  final RxList<AreaModel> areas = <AreaModel>[].obs;
  final Rx<AreaModel?> selectedArea = Rx<AreaModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;
  final RxString searchQuery = ''.obs;

  // Getters
  String? get selectedAreaId => selectedArea.value?.areaId;
  String? get selectedAreaName => selectedArea.value?.name;

  /// Get filtered areas based on search query
  List<AreaModel> get filteredAreas {
    if (searchQuery.value.isEmpty) {
      return areas;
    }
    return areas.where((area) {
      final query = searchQuery.value.toLowerCase();
      return area.name.toLowerCase().contains(query) ||
          area.pin.contains(query);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    // Check if area was previously selected
    _loadSelectedArea();
    // Fetch areas from API
    fetchAreas();
  }

  /// Load previously selected area from storage
  void _loadSelectedArea() {
    final areaId = _storage.getSelectedAreaId();
    final areaName = _storage.getSelectedAreaName();
    if (areaId != null && areaName != null) {
      // Create a placeholder area model until we get full data from API
      selectedArea.value = AreaModel(
        areaId: areaId,
        name: areaName,
        pin: '',
        charge: '0',
      );
      log('📦 Loaded selected area from storage: $areaName');
    }
  }

  /// Fetch areas from API
  Future<void> fetchAreas() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final result = await _apiService.getAreas();

      if (result.success && result.data != null) {
        areas.value = result.data!;
        log('✅ Fetched ${areas.length} areas');

        // Update selected area with full data if it exists
        if (selectedArea.value != null) {
          final fullArea = areas.firstWhereOrNull(
            (area) => area.areaId == selectedArea.value!.areaId,
          );
          if (fullArea != null) {
            selectedArea.value = fullArea;
          }
        }
      } else {
        hasError.value = true;
        errorMessage.value = result.message;
        log('❌ Failed to fetch areas: ${result.message}');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load areas';
      log('❌ Error fetching areas: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Select an area
  void selectArea(AreaModel area) {
    selectedArea.value = area;
    log('📍 Selected area: ${area.name}');
  }

  /// Update search query
  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  /// Clear search
  void clearSearch() {
    searchQuery.value = '';
  }

  /// Confirm area selection and save to storage
  Future<bool> confirmSelection() async {
    if (selectedArea.value == null) {
      Get.snackbar(
        'Error',
        'Please select an area',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    await _storage.saveSelectedArea(
      areaId: selectedArea.value!.areaId,
      areaName: selectedArea.value!.name,
    );

    log('✅ Area selection confirmed: ${selectedArea.value!.name}');
    return true;
  }

  /// Check if an area is selected
  bool get hasSelectedArea => selectedArea.value != null;

  /// Check if areas are loaded
  bool get hasAreas => areas.isNotEmpty;

  /// Check if currently showing empty state
  bool get showEmptyState =>
      !isLoading.value && areas.isEmpty && !hasError.value;
}
