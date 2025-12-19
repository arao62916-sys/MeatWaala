import 'package:get/get.dart';
import 'package:meatwaala_app/data/models/category_model.dart';
import 'package:meatwaala_app/routes/app_routes.dart';

class CategoriesController extends GetxController {
  // Observable list of categories
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  // Load categories
  Future<void> loadCategories() async {
    try {
      isLoading.value = true;

      // TODO: Replace with actual API call
      // Simulating API call with dummy data
      await Future.delayed(const Duration(milliseconds: 500));

      categories.value = [
        CategoryModel(
          id: '1',
          name: 'Chicken',
          imageUrl: 'https://via.placeholder.com/150',
          description: 'Fresh chicken products',
        ),
        CategoryModel(
          id: '2',
          name: 'Mutton',
          imageUrl: 'https://via.placeholder.com/150',
          description: 'Premium mutton cuts',
        ),
        CategoryModel(
          id: '3',
          name: 'Fish',
          imageUrl: 'https://via.placeholder.com/150',
          description: 'Fresh seafood',
        ),
        CategoryModel(
          id: '4',
          name: 'Prawns',
          imageUrl: 'https://via.placeholder.com/150',
          description: 'Fresh prawns',
        ),
        CategoryModel(
          id: '5',
          name: 'Eggs',
          imageUrl: 'https://via.placeholder.com/150',
          description: 'Farm fresh eggs',
        ),
        CategoryModel(
          id: '6',
          name: 'Ready to Cook',
          imageUrl: 'https://via.placeholder.com/150',
          description: 'Marinated and ready to cook',
        ),
      ];
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load categories: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Navigate to product list filtered by category
  void navigateToCategory(String categoryName) {
    Get.toNamed(
      AppRoutes.productList,
      arguments: {'category': categoryName},
    );
  }

  // Refresh categories
  Future<void> onRefresh() async {
    await loadCategories();
  }
}
