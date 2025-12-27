import 'package:meatwaala_app/core/network/base_api_service.dart';
import 'package:meatwaala_app/core/network/network_constents.dart';
import 'package:meatwaala_app/data/models/product_model.dart';

class ProductApiService {
  final BaseApiService _apiService = BaseApiService();

  /// Get sort options
  /// GET: product/sort-option
  Future<ApiResult<Map<String, String>>> getSortOptions() async {
    return await _apiService.get(
      NetworkConstantsUtil.productSortOptions,
      parser: (data) {
        if (data is Map<String, dynamic>) {
          return data.map((key, value) => MapEntry(key, value.toString()));
        }
        return <String, String>{};
      },
    );
  }

  /// Get all products with optional filters
  /// GET: product/list
  /// Optional query params: q (search), sort_order, category_id
  Future<ApiResult<List<ProductModel>>> getProductList({
    String? searchQuery,
    String? sortOrder,
    String? categoryId,
  }) async {
    final Map<String, String> queryParams = {};

    if (searchQuery != null && searchQuery.isNotEmpty) {
      queryParams['q'] = searchQuery;
    }
    if (sortOrder != null && sortOrder.isNotEmpty) {
      queryParams['sort_order'] = sortOrder;
    }

    String endpoint = NetworkConstantsUtil.productList;
    if (categoryId != null && categoryId.isNotEmpty) {
      endpoint = '$endpoint/$categoryId';
    }

    return await _apiService.get(
      endpoint,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      parser: (data) {
        if (data is List) {
          return data.map((e) => ProductModel.fromJson(e)).toList();
        }
        return <ProductModel>[];
      },
    );
  }

  /// Get products by category ID
  /// GET: product/list/{categoryId}
  Future<ApiResult<List<ProductModel>>> getProductsByCategory(
    String categoryId, {
    String? sortOrder,
  }) async {
    final Map<String, String>? queryParams =
        sortOrder != null ? {'sort_order': sortOrder} : null;

    return await _apiService.get(
      '${NetworkConstantsUtil.productList}/$categoryId',
      queryParams: queryParams,
      parser: (data) {
        if (data is List) {
          return data.map((e) => ProductModel.fromJson(e)).toList();
        }
        return <ProductModel>[];
      },
    );
  }

  /// Get product info by ID
  /// GET: product/info/{id}
  Future<ApiResult<ProductDetailModel>> getProductInfo(String productId) async {
    return await _apiService.get(
      '${NetworkConstantsUtil.productInfo}$productId',
      parser: (data) {
        if (data is Map<String, dynamic>) {
          return ProductDetailModel.fromJson(data);
        }
        throw Exception('Invalid product data');
      },
    );
  }

  /// Search products
  /// GET: product/list?q={searchQuery}
  Future<ApiResult<List<ProductModel>>> searchProducts(
    String searchQuery, {
    String? sortOrder,
  }) async {
    return await getProductList(
      searchQuery: searchQuery,
      sortOrder: sortOrder,
    );
  }
}
