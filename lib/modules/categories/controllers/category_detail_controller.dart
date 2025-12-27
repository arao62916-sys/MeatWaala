import 'package:get/get.dart';
import 'package:meatwaala_app/data/models/category_model.dart';
import 'package:meatwaala_app/data/services/category_api_service.dart';
import 'package:meatwaala_app/routes/app_routes.dart';

class CategoryDetailController extends GetxController {
  final CategoryApiService _categoryService = CategoryApiService();

  // State
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Data
  final categoryDetail = Rx<CategoryModel?>(null);
  final subCategories = <CategoryModel>[].obs;

  String categoryId = '';
  String categoryName = '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    categoryId = args?['categoryId']?.toString() ?? '';
    categoryName = args?['categoryName']?.toString() ?? '';

    if (categoryId.isNotEmpty) {
      loadCategoryDetail();
    }
  }

  /// Load category detail with subcategories
  Future<void> loadCategoryDetail() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _categoryService.getCategoryMenuById(categoryId);

      if (result.success && result.data != null && result.data!.isNotEmpty) {
        // The API returns a list, take the first item as the main category
        categoryDetail.value = result.data!.first;

        // Extract subcategories from aChild
        if (categoryDetail.value?.aChild != null) {
          subCategories.value = categoryDetail.value!.aChild!;
        } else {
          subCategories.value = [];
        }
      } else {
        errorMessage.value = result.message.isNotEmpty
            ? result.message
            : 'Failed to load category details';
      }
    } catch (e) {
      errorMessage.value = 'Error loading category: $e';
      Get.snackbar(
        'Error',
        'Failed to load category details',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
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
}
