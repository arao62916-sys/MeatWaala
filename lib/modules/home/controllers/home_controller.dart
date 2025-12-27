import 'package:get/get.dart';
import 'package:meatwaala_app/data/models/category_model.dart';
import 'package:meatwaala_app/data/models/product_model.dart';
import 'package:meatwaala_app/data/services/category_api_service.dart';
import 'package:meatwaala_app/data/services/product_api_service.dart';
import 'package:meatwaala_app/routes/app_routes.dart';

class HomeController extends GetxController {
  final CategoryApiService _categoryService = CategoryApiService();
  final ProductApiService _productService = ProductApiService();

  final isLoading = false.obs;
  final categories = <CategoryModel>[].obs;
  final featuredProducts = <ProductModel>[].obs;
  final products = <ProductModel>[].obs;
  final banners = <String>[].obs;
  final currentBannerIndex = 0.obs;
  final errorMessage = ''.obs;

  // Sort functionality
  final sortOptions = <String, String>{}.obs;
  final selectedSortKey = RxnString();
  final selectedSortLabel = 'Default'.obs;
  final isSortLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
    loadSortOptions();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Load categories from API
      final categoryResult = await _categoryService.getCategoryMenuList();
      if (categoryResult.success && categoryResult.data != null) {
        categories.value = categoryResult.data!;
      } else {
        errorMessage.value = categoryResult.message;
      }

      // Load products from API with optional sort order
      await _loadProducts();

      // TODO: Load banners from API or app configuration
      // For now, banners will be empty unless provided by backend
    } catch (e) {
      errorMessage.value = 'Failed to load data: $e';
      Get.snackbar(
        'Error',
        'Failed to load home data',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load products with current sort order
  Future<void> _loadProducts() async {
    products.clear();
    featuredProducts.clear();
    isSortLoading.value = true;
    try {
      final productResult = await _productService.getProductList(
        sortOrder: selectedSortKey.value,
      );
      if (productResult.success && productResult.data != null) {
        products.assignAll(productResult.data!);
        featuredProducts.assignAll(
          productResult.data!.where((product) => product.isFeatured).toList(),
        );
      }
    } finally {
      isSortLoading.value = false;
    }
  }

  /// Load sort options from API (cached after first load)
  Future<void> loadSortOptions() async {
    // Only load if not already cached
    if (sortOptions.isNotEmpty) return;

    try {
      final result = await _productService.getSortOptions();
      if (result.success && result.data != null) {
        sortOptions.value = result.data!;
      }
    } catch (e) {
      // Silent fail - sort is optional feature
      // User can still use app without sorting
    }
  }

  /// Apply selected sort option
  Future<void> applySortOption(String sortKey, String sortLabel) async {
    if (selectedSortKey.value == sortKey) return; // Already selected

    selectedSortKey.value = sortKey;
    selectedSortLabel.value = sortLabel;

    isSortLoading.value = true;
    try {
      await _loadProducts();
      Get.back(); // Close bottom sheet

      Get.snackbar(
        'Sorted',
        'Products sorted by: $sortLabel',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to apply sorting',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSortLoading.value = false;
    }
  }

  /// Clear sort and show default order
  Future<void> clearSort() async {
    if (selectedSortKey.value == null) return; // Already cleared

    selectedSortKey.value = null;
    selectedSortLabel.value = 'Default';

    isSortLoading.value = true;
    try {
      await _loadProducts();
      Get.back(); // Close bottom sheet

      Get.snackbar(
        'Reset',
        'Showing products in default order',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to reset sorting',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSortLoading.value = false;
    }
  }

  void onBannerChanged(int index) {
    currentBannerIndex.value = index;
  }

  void navigateToCategory(String categoryName) {
    Get.toNamed(
      AppRoutes.productList,
      arguments: {'category': categoryName},
    );
  }

  void navigateToProductDetail(String productId) {
    Get.toNamed(
      AppRoutes.productDetail,
      arguments: {'productId': productId},
    );
  }

  void navigateToCart() {
    Get.toNamed(AppRoutes.cart);
  }

  void navigateToProfile() {
    Get.toNamed(AppRoutes.profile);
  }

  void navigateToOrders() {
    Get.toNamed(AppRoutes.orderHistory);
  }

  Future<void> onRefresh() async {
    await loadData();
  }

  void navigateToCategoryDetail(String categoryId, String categoryName) {
    Get.toNamed(
      AppRoutes.categoryDetail,
      arguments: {
        'categoryId': categoryId,
        'categoryName': categoryName,
      },
    );
  }
}
