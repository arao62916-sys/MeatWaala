import 'package:get/get.dart';
import 'package:meatwaala_app/data/models/category_model.dart';
import 'package:meatwaala_app/data/services/category_api_service.dart';
import 'package:meatwaala_app/routes/app_routes.dart';

class CategoryInfoController extends GetxController {
  final CategoryApiService _categoryService = CategoryApiService();

  // Arguments
  late String categoryId;
  late String categoryName;

  // State
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final Rxn<CategoryModel> categoryInfo = Rxn<CategoryModel>();
  final RxList<CategoryModel> subCategories = <CategoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Get arguments from navigation
    final args = Get.arguments as Map<String, dynamic>;
    categoryId = args['categoryId'] as String;
    categoryName = args['categoryName'] as String;

    loadCategoryInfo();
  }

  /// Load category info with subcategories
  Future<void> loadCategoryInfo() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Call the category-info API
      final result = await _categoryService.getCategoryListById(categoryId);

      if (result.success && result.data != null && result.data!.isNotEmpty) {
        categoryInfo.value = result.data!.first;

        // Extract subcategories from aChild property
        subCategories.value = categoryInfo.value?.aChild ?? [];
      } else {
        errorMessage.value = result.message;
        Get.snackbar(
          'Error',
          result.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      errorMessage.value = 'Failed to load category info';
      Get.snackbar(
        'Error',
        'Failed to load category info: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigate to product list
  void navigateToProductList() {
    if (categoryInfo.value != null) {
      Get.toNamed(
        AppRoutes.productList,
        arguments: {
          'categoryId': categoryInfo.value!.categoryId,
          'categoryName': categoryInfo.value!.name,
        },
      );
    }
  }

  /// Refresh category info
  Future<void> refreshCategoryInfo() async {
    await loadCategoryInfo();
  }
}
