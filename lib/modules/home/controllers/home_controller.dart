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

  @override
  void onInit() {
    super.onInit();
    loadData();
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

      // Load products from API
      final productResult = await _productService.getProductList();
      if (productResult.success && productResult.data != null) {
        // Store all products
        products.value = productResult.data!;

        // Filter featured products
        featuredProducts.value =
            productResult.data!.where((product) => product.isFeatured).toList();
      }

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
