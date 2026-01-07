/// Product model matching API response
class ProductModel {
  final String productId;
  final String menuId;
  final String categoryId;
  final String url;
  final String code;
  final String name;
  final String packing;
  final String mrp;
  final String price;
  final String weight;
  final String weightUnit;
  final String tag;
  final String shortDescription;
  final String description;
  final String title;
  final String image;
  final String reviews;
  final String rating;
  final String youtube;
  final String status;
  final String menu;
  final String category;
  final String infoLink;
  final String imageUrl;

  ProductModel({
    required this.productId,
    required this.menuId,
    required this.categoryId,
    required this.url,
    required this.code,
    required this.name,
    required this.packing,
    required this.mrp,
    required this.price,
    required this.weight,
    required this.weightUnit,
    required this.tag,
    required this.shortDescription,
    required this.description,
    required this.title,
    required this.image,
    required this.reviews,
    required this.rating,
    required this.youtube,
    required this.status,
    required this.menu,
    required this.category,
    required this.infoLink,
    required this.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['product_id']?.toString() ?? '',
      menuId: json['menu_id']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      url: json['url'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      packing: json['packing'] ?? '',
      mrp: json['mrp']?.toString() ?? '0',
      price: json['price']?.toString() ?? '0',
      weight: json['weight']?.toString() ?? '',
      weightUnit: json['weight_unit'] ?? '',
      tag: json['tag'] ?? '',
      shortDescription: json['short_description'] ?? '',
      description: json['description'] ?? '',
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      reviews: json['reviews']?.toString() ?? '0',
      rating: json['rating']?.toString() ?? '0',
      youtube: json['youtube'] ?? '',
      status: json['status'] ?? '',
      menu: json['menu'] ?? '',
      category: json['category'] ?? '',
      infoLink: json['info_link'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'menu_id': menuId,
      'category_id': categoryId,
      'url': url,
      'code': code,
      'name': name,
      'packing': packing,
      'mrp': mrp,
      'price': price,
      'weight': weight,
      'weight_unit': weightUnit,
      'tag': tag,
      'short_description': shortDescription,
      'description': description,
      'title': title,
      'image': image,
      'reviews': reviews,
      'rating': rating,
      'youtube': youtube,
      'status': status,
      'menu': menu,
      'category': category,
      'info_link': infoLink,
      'image_url': imageUrl,
    };
  }

  // Helper getters
  double get mrpDouble => double.tryParse(mrp) ?? 0.0;
  double get priceDouble => double.tryParse(price) ?? 0.0;
  double get ratingDouble => double.tryParse(rating) ?? 0.0;
  int get reviewsInt => int.tryParse(reviews) ?? 0;
  bool get isAvailable => status == 'Enabled';
  bool get hasDiscount => mrpDouble > priceDouble;

  String get discountPercentage {
    if (!hasDiscount) return '';
    final discount = ((mrpDouble - priceDouble) / mrpDouble * 100).round();
    return '$discount% OFF';
  }

  // Compatibility getters for UI
  String get id => productId;
  double get basePrice => priceDouble;
  String? get discount => hasDiscount ? discountPercentage : null;
  int get reviewCount => reviewsInt;
  List<String> get images => [imageUrl];
  List<String> get availableWeights => [weight + weightUnit];
  bool get isFeatured => tag.toLowerCase().contains('featured');
}

/// Product image model
class ProductImageModel {
  final String imageId;
  final String productId;
  final String image;

  ProductImageModel({
    required this.imageId,
    required this.productId,
    required this.image,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      imageId: json['image_id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      image: json['image'] ?? '',
    );
  }
}

/// Product review model
class ProductReviewModel {
  final String id;
  final String orderId;
  final String reviewDate;
  final String reviewTitle;
  final String review;
  final String rating;
  final String reviewHelpful;
  final String reviewUnhelpful;
  final String name;

  ProductReviewModel({
    required this.id,
    required this.orderId,
    required this.reviewDate,
    required this.reviewTitle,
    required this.review,
    required this.rating,
    required this.reviewHelpful,
    required this.reviewUnhelpful,
    required this.name,
  });

  factory ProductReviewModel.fromJson(Map<String, dynamic> json) {
    return ProductReviewModel(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '0',
      reviewDate: json['review_date'] ?? '',
      reviewTitle: json['review_title'] ?? '',
      review: json['review'] ?? '',
      rating: json['rating']?.toString() ?? '0',
      reviewHelpful: json['review_helpful']?.toString() ?? '0',
      reviewUnhelpful: json['review_unhelpful']?.toString() ?? '0',
      name: json['name'] ?? '',
    );
  }

  double get ratingDouble => double.tryParse(rating) ?? 0.0;
  int get helpfulCount => int.tryParse(reviewHelpful) ?? 0;
  int get unhelpfulCount => int.tryParse(reviewUnhelpful) ?? 0;
}
class ProductDetailModel extends ProductModel {
  final String entryDate;
  final String? editDate;
  final String stockStatus;
  final String metaDescription;
  final String metaKeywords;
  final String? ratingSymbol;
  final String? entryInfo;
  final String? editInfo;
  final String menuUrl;
  final String categoryUrl;
  final List<ProductImageModel> aImage;
  final Map<String, ProductReviewModel> aReview;

  ProductDetailModel({
    required super.productId,
    required super.menuId,
    required super.categoryId,
    required super.url,
    required super.code,
    required super.name,
    required super.packing,
    required super.mrp,
    required super.price,
    required super.weight,
    required super.weightUnit,
    required super.tag,
    required super.shortDescription,
    required super.description,
    required super.title,
    required super.image,
    required super.reviews,
    required super.rating,
    required super.youtube,
    required super.status,
    required super.menu,
    required super.category,
    required super.infoLink,
    required super.imageUrl,
    required this.entryDate,
    this.editDate,
    required this.stockStatus,
    required this.metaDescription,
    required this.metaKeywords,
    this.ratingSymbol,
    this.entryInfo,
    this.editInfo,
    required this.menuUrl,
    required this.categoryUrl,
    required this.aImage,
    required this.aReview,
  });

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    // The API returns data in this structure: {status, message, data, aImage, aReview}
    // Parse main product data from 'data' key
    final data = json['data'] as Map<String, dynamic>? ?? json;
    
    return ProductDetailModel(
      productId: data['product_id']?.toString() ?? '',
      menuId: data['menu_id']?.toString() ?? '',
      categoryId: data['category_id']?.toString() ?? '',
      url: data['url'] ?? '',
      code: data['code'] ?? '',
      name: data['name'] ?? '',
      packing: data['packing'] ?? '',
      mrp: data['mrp']?.toString() ?? '0',
      price: data['price']?.toString() ?? '0',
      weight: data['weight']?.toString() ?? '',
      weightUnit: data['weight_unit'] ?? '',
      tag: data['tag'] ?? '',
      shortDescription: data['short_description'] ?? '',
      description: data['description'] ?? '',
      title: data['title'] ?? '',
      image: data['image'] ?? '',
      reviews: data['reviews']?.toString() ?? '0',
      rating: data['rating']?.toString() ?? '0',
      youtube: data['youtube'] ?? '',
      status: data['status'] ?? '',
      menu: data['menu'] ?? '',
      category: data['category'] ?? '',
      infoLink: data['info_link'] ?? '',
      imageUrl: data['image_url'] ?? '',
      entryDate: data['entry_date'] ?? '',
      editDate: data['edit_date'],
      stockStatus: data['stock_status'] ?? '',
      metaDescription: data['meta_description'] ?? '',
      metaKeywords: data['meta_keywords'] ?? '',
      ratingSymbol: data['rating_symbol'],
      entryInfo: data['entry_info'],
      editInfo: data['edit_info'],
      menuUrl: data['menu_url'] ?? '',
      categoryUrl: data['category_url'] ?? '',
      // aImage and aReview are at root level, not inside 'data'
      aImage: json['aImage'] != null
          ? (json['aImage'] as List)
              .map((e) => ProductImageModel.fromJson(e))
              .toList()
          : [],
      aReview: json['aReview'] != null
          ? (json['aReview'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                key,
                ProductReviewModel.fromJson(value),
              ),
            )
          : {},
    );
  }

  /// Get all product images (main + additional)
  List<String> get images {
    final imageList = <String>[imageUrl];
    imageList.addAll(aImage.map((img) => img.image));
    return imageList;
  }

  /// Get reviews as list sorted by date (newest first)
  List<ProductReviewModel> get reviewsList {
    final reviews = aReview.values.toList();
    reviews.sort((a, b) => b.reviewDate.compareTo(a.reviewDate));
    print('📝 Reviews count: ${reviews.length}'); // Debug log
    return reviews;
  }

  /// Check if product is in stock
  bool get isInStock => stockStatus.toLowerCase() != 'out of stock';

  /// Get review count
  int get reviewCount => int.tryParse(reviews) ?? 0;

  /// Get average rating
  double get averageRating => double.tryParse(rating) ?? 0.0;
}