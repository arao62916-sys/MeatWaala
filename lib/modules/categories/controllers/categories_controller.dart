import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/core/services/app_snackbar.dart';
import 'package:meatwaala_app/data/models/category_model.dart';
import 'package:meatwaala_app/data/services/category_api_service.dart';
import 'package:meatwaala_app/routes/app_routes.dart';

class CategoriesController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final CategoryApiService _categoryService = CategoryApiService();

  // Tab Controller
  TabController? tabController;

  // Menu Categories (Dynamic from API)
  final RxList<CategoryModel> menuCategories = <CategoryModel>[].obs;

  // Observable lists
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  // State
  final RxBool isLoading = false.obs;
  final RxBool isMenuLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt selectedTabIndex = 0.obs;
  final RxBool showAllCategories = true.obs; // Track if showing all or filtered

  @override
  void onInit() {
    super.onInit();
    _initializeScreen();
  }

  /// Initialize screen: Load menu items and all categories
  Future<void> _initializeScreen() async {
    await loadMenuCategories();
    await loadAllCategories();
  }

  @override
  void onClose() {
    tabController?.dispose();
    super.onClose();
  }

  /// Load menu categories from API
  Future<void> loadMenuCategories() async {
    try {
      isMenuLoading.value = true;

      final result = await _categoryService.getCategoryMenuList();

      if (result.success && result.data != null) {
        // Insert synthetic 'All' tab at the start
        final allMenu = CategoryModel(
          categoryId: 'all',
          name: 'All',
          image: '',
          shortDescription: '',
          aChild: [],
          type: '', // Provide an appropriate value for 'type' if needed
        );
        menuCategories.value = [allMenu, ...result.data!];

        // Setup tab controller after menu items are loaded
        if (menuCategories.isNotEmpty) {
          tabController = TabController(
            length: menuCategories.length,
            vsync: this,
          );
          tabController!.addListener(() {
            if (!tabController!.indexIsChanging) {
              selectedTabIndex.value = tabController!.index;
              if (tabController!.index == 0) {
                // 'All' tab selected
                loadAllCategories();
              } else {
                final selectedMenu = menuCategories[tabController!.index];
                loadCategoryInfoWithChildren(selectedMenu.categoryId);
              }
            }
          });
        }
      } else {
        AppSnackbar.error(result.message);
      }
    } catch (e) {
      AppSnackbar.error('Failed to load menu categories: $e');
    } finally {
      isMenuLoading.value = false;
    }
  }

  /// Load all categories (default view on screen load)
  Future<void> loadAllCategories() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      showAllCategories.value = true;

      final result = await _categoryService.getCategoryList();

      if (result.success && result.data != null) {
        categories.value = result.data!;
      } else {
        errorMessage.value = result.message;
        AppSnackbar.error(result.message);
      }
    } catch (e) {
      errorMessage.value = 'Failed to load categories';
      AppSnackbar.error('Failed to load categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load category info with children (when filter is selected)
  Future<void> loadCategoryInfoWithChildren(String categoryId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      showAllCategories.value = false;

      final result =
          await _categoryService.getCategoryInfoWithChildren(categoryId);

      if (result.success && result.data != null) {
        final categoryData = result.data!;

        // Use children if available, otherwise show empty list
        if (categoryData.aChild.isNotEmpty) {
          categories.value = categoryData.aChild;
        } else {
          categories.value = [];
          errorMessage.value = 'No child categories available';
        }
      } else {
        errorMessage.value = result.message;
        categories.value = [];
        AppSnackbar.error(result.message);
      }
    } catch (e) {
      errorMessage.value = 'Failed to load category details';
      categories.value = [];
      AppSnackbar.error('Failed to load category details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigate to product list screen for selected category
  void navigateToProductList(String categoryId, String categoryName) {
    Get.toNamed(
      AppRoutes.productList,
      arguments: {
        'categoryId': categoryId,
        'categoryName': categoryName,
      },
    );
  }

  /// Refresh categories (reload based on current state)
  Future<void> refreshCategories() async {
    if (showAllCategories.value) {
      await loadAllCategories();
    } else {
      // Reload current selected filter
      if (menuCategories.isNotEmpty &&
          selectedTabIndex.value < menuCategories.length) {
        final selectedMenu = menuCategories[selectedTabIndex.value];
        await loadCategoryInfoWithChildren(selectedMenu.categoryId);
      }
    }
  }

  /// Reset to show all categories (clear filter)
  Future<void> resetToAllCategories() async {
    if (tabController != null) {
      tabController!.index = 0;
    }
    await loadAllCategories();
  }
}
