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

/// Product detail model with images and reviews
class ProductDetailModel extends ProductModel {
  final String entryDate;
  final String? editDate;
  final String stockStatus;
  final String metaDescription;
  final String metaKeywords;
  final String? ratingSymbol;
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
    required this.menuUrl,
    required this.categoryUrl,
    required this.aImage,
    required this.aReview,
  });

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    return ProductDetailModel(
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
      entryDate: json['entry_date'] ?? '',
      editDate: json['edit_date'],
      stockStatus: json['stock_status'] ?? '',
      metaDescription: json['meta_description'] ?? '',
      metaKeywords: json['meta_keywords'] ?? '',
      ratingSymbol: json['rating_symbol'],
      menuUrl: json['menu_url'] ?? '',
      categoryUrl: json['category_url'] ?? '',
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
}

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
      orderId: json['order_id']?.toString() ?? '',
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
}
