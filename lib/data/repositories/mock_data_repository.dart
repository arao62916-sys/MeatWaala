import 'package:meatwaala_app/data/models/product_model.dart';
import 'package:meatwaala_app/data/models/category_model.dart';

/// Mock Data Repository - Deprecated
/// Use actual API services instead: CategoryApiService, ProductApiService
class MockDataRepository {
  // Returns empty list - use CategoryApiService.getCategoryMenuList() instead
  static List<CategoryModel> getCategories() {
    return [];
  }

  // Returns empty list - use ProductApiService.getProductList() instead
  static List<ProductModel> getProducts() {
    return [];
  }

  // Returns empty list - use ProductApiService with category filter
  static List<ProductModel> getProductsByCategory(String category) {
    return [];
  }

  // Returns empty list - use ProductApiService with featured filter
  static List<ProductModel> getFeaturedProducts() {
    return [];
  }

  // Returns null - use ProductApiService.getProductInfo(id)
  static ProductModel? getProductById(String id) {
    return null;
  }

  // Returns empty list - banners should come from API or app config
  static List<String> getBanners() {
    return [];
  }
}
