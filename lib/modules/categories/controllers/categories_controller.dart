import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/data/models/category_model.dart';
import 'package:meatwaala_app/data/services/category_api_service.dart';
import 'package:meatwaala_app/routes/app_routes.dart';

class CategoriesController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final CategoryApiService _categoryService = CategoryApiService();

  // Tab Controller
  late TabController tabController;

  // Parent Categories
  final List<Map<String, String>> parentCategories = [
    {'id': '1', 'name': 'Chicken'},
    {'id': '2', 'name': 'Mutton'},
    {'id': '3', 'name': 'Fish'},
    {'id': '4', 'name': 'Eggs'},
    {'id': '5', 'name': 'Spices'},
  ];

  // Observable lists
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  // State
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt selectedTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(
      length: parentCategories.length,
      vsync: this,
    );
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        selectedTabIndex.value = tabController.index;
        loadCategoriesByParentId(parentCategories[tabController.index]['id']!);
      }
    });
    loadCategoriesByParentId('1'); // Load Chicken categories by default
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  /// Load categories by parent ID
  Future<void> loadCategoriesByParentId(String parentId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _categoryService.getCategoryListById(parentId);

      if (result.success && result.data != null) {
        categories.value = result.data!;
      } else {
        errorMessage.value = result.message;
        Get.snackbar(
          'Error',
          result.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      errorMessage.value = 'Failed to load categories';
      Get.snackbar(
        'Error',
        'Failed to load categories: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigate to category info screen
  void navigateToCategoryInfo(String categoryId, String categoryName) {
    Get.toNamed(
      AppRoutes.categoryInfo,
      arguments: {
        'categoryId': categoryId,
        'categoryName': categoryName,
      },
    );
  }

  /// Refresh categories
  Future<void> refreshCategories() async {
    await loadCategoriesByParentId(
      parentCategories[selectedTabIndex.value]['id']!,
    );
  }
}
