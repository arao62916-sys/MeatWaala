import 'package:get/get.dart';
import 'package:meatwaala_app/data/models/category_model.dart';
import 'package:meatwaala_app/data/models/product_model.dart';
import 'package:meatwaala_app/data/repositories/mock_data_repository.dart';
import 'package:meatwaala_app/routes/app_routes.dart';

class HomeController extends GetxController {
  final isLoading = false.obs;
  final categories = <CategoryModel>[].obs;
  final featuredProducts = <ProductModel>[].obs;
  final banners = <String>[
    "https://images.unsplash.com/photo-1604908554166-35b5b7e5e3e4",
    "https://images.unsplash.com/photo-1600891964599-f61ba0e24092",
    "https://images.unsplash.com/photo-1603048297172-c92544798d5a",
  ].obs;

  final currentBannerIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    categories.value = MockDataRepository.getCategories();
    featuredProducts.value = MockDataRepository.getFeaturedProducts();
    banners.value = MockDataRepository.getBanners();

    isLoading.value = false;
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
}
