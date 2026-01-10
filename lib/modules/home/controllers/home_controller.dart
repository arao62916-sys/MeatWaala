import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:meatwaala_app/core/services/app_snackbar.dart';
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

  // Search functionality
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final isSearching = false.obs;
  Worker? _searchDebouncer;
  Timer? _debounceTimer;

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
    _initializeSearch();
  }

  void _initializeSearch() {
    // Debounce search input to avoid excessive API calls
    _searchDebouncer = debounce(
      searchQuery,
      (_) {
        print('Debounce triggered with query: ${searchQuery.value}');
        _performSearch();
      },
      time: const Duration(milliseconds: 500),
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    _searchDebouncer?.dispose();
    _debounceTimer?.cancel();
    super.onClose();
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
      AppSnackbar.error('Failed to load home data');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load products with current sort order and search query
  Future<void> _loadProducts() async {
    products.clear();
    featuredProducts.clear();
    isSortLoading.value = true;
    try {
      final productResult = await _productService.getProductList(
        sortOrder: selectedSortKey.value,
        searchQuery: searchQuery.value.isEmpty ? null : searchQuery.value,
      );
      if (productResult.success && productResult.data != null) {
        products.assignAll(productResult.data!);
        // Only show featured products when not searching
        if (searchQuery.value.isEmpty) {
          featuredProducts.assignAll(
            productResult.data!.where((product) => product.isFeatured).toList(),
          );
        }
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

      AppSnackbar.success('Products sorted by: $sortLabel', title: 'Sorted');
    } catch (e) {
      AppSnackbar.error('Failed to apply sorting');
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

      AppSnackbar.info('Showing products in default order', title: 'Reset');
    } catch (e) {
      AppSnackbar.error('Failed to reset sorting');
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

  /// Handle search query changes
  void onSearchChanged(String query) {
    print('Search changed: "$query"');

    // Cancel previous timer if exists
    _debounceTimer?.cancel();

    // Update the search query
    searchQuery.value = query.trim();
    print('Search query observable updated to: "${searchQuery.value}"');

    // Start new timer for debounce
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      print('Timer fired, calling _performSearch()');
      _performSearch();
    });
  }

  /// Perform the actual search
  Future<void> _performSearch() async {
    print('_performSearch called with query: "${searchQuery.value}"');
    if (isSearching.value) {
      print('Already searching, skipping...');
      return; // Prevent concurrent searches
    }

    isSearching.value = true;
    try {
      await _loadProducts();

      // Show feedback for empty results
      if (searchQuery.value.isNotEmpty && products.isEmpty) {
        // UI will handle displaying "No products found" message
        print('Search completed: No products found');
      } else {
        print('Search completed: ${products.length} products found');
      }
    } catch (e) {
      print('Search error: $e');
      AppSnackbar.error('Failed to search products');
    } finally {
      isSearching.value = false;
    }
  }

  /// Clear search and reset to default view
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    _performSearch(); // Reload default products
  }

  void navigateToCategoryDetail(String categoryId, String categoryName) {
    Get.toNamed(
      AppRoutes.categoryChildrenInfo,
      arguments: {
        'categoryId': categoryId,
        'categoryName': categoryName,
      },
    );
  }
}
