class CategoryModel {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final int productCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    this.productCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      productCount: json['productCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
      'productCount': productCount,
    };
  }
}
