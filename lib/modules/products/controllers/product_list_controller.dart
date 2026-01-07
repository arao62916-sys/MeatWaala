import 'package:get/get.dart';
import 'package:meatwaala_app/core/services/app_snackbar.dart';
import 'package:meatwaala_app/data/models/product_model.dart';
import 'package:meatwaala_app/data/services/product_api_service.dart';
import 'package:meatwaala_app/routes/app_routes.dart';

class ProductListController extends GetxController {
  final ProductApiService _productService = ProductApiService();

  // State
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Data
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<ProductModel> filteredProducts = <ProductModel>[].obs;
  final RxMap<String, String> sortOptions = <String, String>{}.obs;

  // Filters
  final RxString categoryId = ''.obs;
  final RxString categoryName = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedSortOrder = ''.obs;
  final RxString selectedSortKey = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Get arguments passed from navigation
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      categoryId.value = args['categoryId']?.toString() ?? '';
      categoryName.value = args['categoryName']?.toString() ?? '';
    }

    loadSortOptions();
    loadProducts();
  }

  /// Load sort options from API
  Future<void> loadSortOptions() async {
    try {
      final result = await _productService.getSortOptions();

      if (result.success && result.data != null) {
        sortOptions.value = result.data!;
      }
    } catch (e) {
      // Silently fail for sort options
      print('Failed to load sort options: $e');
    }
  }

  /// Load products based on current filters
  Future<void> loadProducts() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _productService.getProductList(
        categoryId: categoryId.value.isNotEmpty ? categoryId.value : null,
        searchQuery: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        sortOrder:
            selectedSortKey.value.isNotEmpty ? selectedSortKey.value : null,
      );

      if (result.success && result.data != null) {
        products.value = result.data!;
        filteredProducts.value = result.data!;
      } else {
        errorMessage.value = result.message;
        AppSnackbar.error(result.message);
      }
    } catch (e) {
      errorMessage.value = 'Failed to load products';
      AppSnackbar.error('Failed to load products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Search products
  void searchProducts(String query) {
    searchQuery.value = query;
    loadProducts();
  }

  /// Apply sort order
  void applySortOrder(String sortKey, String sortLabel) {
    selectedSortKey.value = sortKey;
    selectedSortOrder.value = sortLabel;
    loadProducts();
  }

  /// Clear filters
  void clearFilters() {
    searchQuery.value = '';
    selectedSortKey.value = '';
    selectedSortOrder.value = '';
    loadProducts();
  }

  /// Refresh products
  Future<void> refreshProducts() async {
    await loadProducts();
  }

  /// Navigate to product detail
  void navigateToProductDetail(ProductModel product) {
    Get.toNamed(
      AppRoutes.productDetail,
      arguments: {
        'productId': product.productId,
        'product': product,
      },
    );
  }
}
