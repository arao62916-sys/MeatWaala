class ProductModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String imageUrl;
  final List<String> images;
  final double basePrice;
  final Map<String, double> weightPrices; // e.g., {'250g': 150, '500g': 280}
  final List<String> availableWeights;
  final bool isAvailable;
  final bool isFeatured;
  final double rating;
  final int reviewCount;
  final String? discount;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.imageUrl,
    this.images = const [],
    required this.basePrice,
    required this.weightPrices,
    required this.availableWeights,
    this.isAvailable = true,
    this.isFeatured = false,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.discount,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      basePrice: (json['basePrice'] ?? 0).toDouble(),
      weightPrices: Map<String, double>.from(
        (json['weightPrices'] ?? {}).map(
          (key, value) => MapEntry(key.toString(), value.toDouble()),
        ),
      ),
      availableWeights: List<String>.from(json['availableWeights'] ?? []),
      isAvailable: json['isAvailable'] ?? true,
      isFeatured: json['isFeatured'] ?? false,
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      discount: json['discount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'images': images,
      'basePrice': basePrice,
      'weightPrices': weightPrices,
      'availableWeights': availableWeights,
      'isAvailable': isAvailable,
      'isFeatured': isFeatured,
      'rating': rating,
      'reviewCount': reviewCount,
      'discount': discount,
    };
  }

  double getPriceForWeight(String weight) {
    return weightPrices[weight] ?? basePrice;
  }
}
