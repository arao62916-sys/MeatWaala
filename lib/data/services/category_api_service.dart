import 'dart:convert';
import 'package:http/http.dart' as http;
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
      '${NetworkConstantsUtil.productCategoryInfoById}/$menuId/1',
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

  /// Get category info with children by category ID
  /// GET: product/category-info/{id}/1
  /// Returns category data with aChild array containing child categories
  Future<ApiResult<CategoryModel>> getCategoryInfoWithChildren(
      String categoryId) async {
    try {
      print('📡 CategoryApiService: Making direct HTTP call');
      print('   Category ID: $categoryId');
      // Make direct HTTP call to preserve aChild array
      final url = Uri.parse(
          '${NetworkConstantsUtil.baseUrl}${NetworkConstantsUtil.productCategoryInfoById}/$categoryId/1');
      print('   URL: $url');
      final response = await http.get(
        url,
        headers: {
          // 'Content-Type': 'application/json',
          // 'Accept': 'application/json',
          'Authorization': 'Bearer ${NetworkConstantsUtil.bearerToken}',
        },
      );
      print('✅ HTTP Response received');
      print('   Status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = json.decode(response.body);
        print('   Response keys: ${decoded.keys}');
        final int apiStatus = decoded['status'] ?? 0;
        final String message = decoded['message'] ?? '';
        if (apiStatus == 1) {
          // Extract parent category from 'data'
          final Map<String, dynamic> parentData =
              decoded['data'] as Map<String, dynamic>;
          // Extract children from 'aChild' (sibling to 'data')
          List<CategoryModel> children = [];
          if (decoded.containsKey('aChild') && decoded['aChild'] is List) {
            final List childrenList = decoded['aChild'] as List;
            print('   Found ${childrenList.length} children');
            children = childrenList
                .map((child) =>
                    CategoryModel.fromJson(child as Map<String, dynamic>))
                .toList();
          } else {
            print('   No aChild found');
          }
          // Build parent with children (pass aChild as List<Map<String, dynamic>>)
          final CategoryModel category = CategoryModel.fromJson({
            ...parentData,
            'aChild': children.map((e) => e.toJson()).toList(),
          });
          print('✅ Parsing complete');
          print('   Parent: ${category.heading}');
          print('   Children: ${category.aChild.length}');
          return ApiResult.success(
            category,
            message: message,
            status: apiStatus,
          );
        } else {
          print('❌ API error: $apiStatus - $message');
          return ApiResult.error(message, status: apiStatus);
        }
      } else {
        print('❌ HTTP error: ${response.statusCode}');
        return ApiResult.error(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e, stack) {
      print('❌ Exception: $e');
      print('   Stack: $stack');
      return ApiResult.error('Failed to load category: $e');
    }
  }
}
