import 'dart:math';

import 'package:get/get.dart';
import 'package:meatwaala_app/core/services/app_snackbar.dart';
import 'package:meatwaala_app/data/models/category_model.dart';
import 'package:meatwaala_app/data/services/category_api_service.dart';
import 'package:meatwaala_app/routes/app_routes.dart';

class CategoryChildrenInfoController extends GetxController {
  final CategoryApiService _categoryService = CategoryApiService();

  // State
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Data - Updated to use CategoryInfoResponse structure
  final categoryDetail = Rx<CategoryModel?>(null);
  final subCategories = <CategoryModel>[].obs;

  String categoryId = '';
  final categoryName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    categoryId = args?['categoryId']?.toString() ?? '';
    categoryName.value = args?['categoryName']?.toString() ?? '';

    if (categoryId.isNotEmpty) {
      loadCategoryDetail();
    }
  }

  /// Load category detail with child categories using Category Info API
  /// API: product/category-info/{id}/1
  Future<void> loadCategoryDetail() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('📌 [Category] Loading category info for ID => $categoryId');

      final result =
          await _categoryService.getCategoryInfoWithChildren(categoryId);

      print('📦 [Category] API Result => success: ${result.success}');
      print('📦 [Category] API Message => ${result.message}');
      print('📦 [Category] Raw Data => ${result.data}');

      if (result.success && result.data != null) {
        // Set main category info
        categoryDetail.value = result.data;

        print('✅ [Category] Category ID => ${result.data!.categoryId}');
        print('✅ [Category] Category Name => ${result.data!.name}');
        print('📂 [Category] aChild RAW => ${result.data!.aChild}');
        print('📂 [Category] aChild COUNT => ${result.data!.aChild.length}');

        // Extract child categories
        subCategories.value = result.data!.aChild;

        // Log each subcategory
        for (var child in subCategories) {
          print(
              '➡️ [SubCategory] ID: ${child.categoryId}, Name: ${child.name}');
        }

        // Update category name if available and not already set
        if (categoryName.value.isEmpty) {
          categoryName.value = result.data!.name;
        }
      } else {
        print('❌ [Category] API failed or data is null');

        errorMessage.value = result.message.isNotEmpty
            ? result.message
            : 'Failed to load category details';
      }
    } catch (e, stackTrace) {
      print('🔥 [Category] Exception => $e');
      print('🧵 [Category] StackTrace => $stackTrace');

      errorMessage.value = 'Error loading category: $e';

      AppSnackbar.error('Failed to load category details');
    } finally {
      isLoading.value = false;
      print('⏹️ [Category] Loading finished');
    }
  }

  /// Navigate to product list with selected category
  void navigateToProductList(CategoryModel category) {
    Get.toNamed(
      AppRoutes.productList,
      arguments: {
        'categoryId': category.categoryId,
        'categoryName': category.name,
      },
    );
  }

  /// Refresh category detail
  Future<void> refreshCategoryDetail() async {
    await loadCategoryDetail();
  }

  /// Check if category has children
  bool get hasChildren => subCategories.isNotEmpty;

  /// Get children count
  int get childrenCount => subCategories.length;
}
