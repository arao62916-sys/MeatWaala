import 'package:meatwaala_app/core/network/base_api_service.dart';
import 'package:meatwaala_app/core/network/network_constents.dart';
import 'package:meatwaala_app/data/models/category_model.dart';

class CategoryApiService {
  final BaseApiService _apiService = BaseApiService();

  /// Get all category menus
  /// GET: product/category/menu/
  Future<ApiResult<List<CategoryModel>>> getCategoryMenuList() async {
    return await _apiService.get(
      NetworkConstantsUtil.productCategoryMenu,
      parser: (data) {
        if (data is List) {
          return data.map((e) => CategoryModel.fromJson(e)).toList();
        }
        return <CategoryModel>[];
      },
    );
  }

  /// Get category menu by ID with children
  /// GET: product/category/menu/{id}
  Future<ApiResult<List<CategoryModel>>> getCategoryMenuById(
      String menuId) async {
    return await _apiService.get(
      '${NetworkConstantsUtil.productCategoryMenu}/$menuId',
      parser: (data) {
        if (data is List) {
          return data.map((e) => CategoryModel.fromJson(e)).toList();
        }
        return <CategoryModel>[];
      },
    );
  }

  /// Get all categories (simple category list)
  /// GET: product/category/category
  Future<ApiResult<List<CategoryModel>>> getCategoryList() async {
    return await _apiService.get(
      NetworkConstantsUtil.productCategory,
      parser: (data) {
        if (data is List) {
          return data.map((e) => CategoryModel.fromJson(e)).toList();
        }
        return <CategoryModel>[];
      },
    );
  }

  /// Get categories by parent ID
  /// GET: product/category/category/{id}
  Future<ApiResult<List<CategoryModel>>> getCategoryListById(
      String categoryId) async {
    return await _apiService.get(
      '${NetworkConstantsUtil.productCategoryById}$categoryId',
      parser: (data) {
        if (data is List) {
          return data.map((e) => CategoryModel.fromJson(e)).toList();
        }
        return <CategoryModel>[];
      },
    );
  }

  /// Get category info by ID
  /// GET: product/category-info/{id}
  Future<ApiResult<CategoryModel>> getCategoryInfo(String categoryId) async {
    return await _apiService.get(
      '${NetworkConstantsUtil.productCategoryInfoById}$categoryId',
      parser: (data) {
        if (data is Map<String, dynamic>) {
          return CategoryModel.fromJson(data);
        }
        throw Exception('Invalid category data');
      },
    );
  }

  /// Get all categories (both menu and category types)
  /// GET: product/category
  Future<ApiResult<List<CategoryModel>>> getAllCategories() async {
    return await _apiService.get(
      NetworkConstantsUtil.productCategoryInfo,
      parser: (data) {
        if (data is List) {
          return data.map((e) => CategoryModel.fromJson(e)).toList();
        }
        return <CategoryModel>[];
      },
    );
  }
}
