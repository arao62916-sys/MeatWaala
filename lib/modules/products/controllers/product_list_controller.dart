import 'package:get/get.dart';
import 'package:meatwaala_app/data/models/product_model.dart';
import 'package:meatwaala_app/data/repositories/mock_data_repository.dart';
import 'package:meatwaala_app/routes/app_routes.dart';

class ProductListController extends GetxController {
  final isLoading = false.obs;
  final products = <ProductModel>[].obs;
  final category = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    category.value = args?['category'] ?? '';
    loadProducts();
  }

  Future<void> loadProducts() async {
    isLoading.value = true;

    await Future.delayed(const Duration(milliseconds: 500));

    if (category.value.isNotEmpty) {
      products.value = MockDataRepository.getProductsByCategory(category.value);
    } else {
      products.value = MockDataRepository.getProducts();
    }

    isLoading.value = false;
  }

  void navigateToProductDetail(String productId) {
    Get.toNamed(
      AppRoutes.productDetail,
      arguments: {'productId': productId},
    );
  }
}
