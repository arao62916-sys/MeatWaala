/// Category model matching API response
class CategoryModel {
  final String categoryId;
  final String type; // "Menu" or "Category"
  final String name;
  final String heading;
  final String title;
  final String url;
  final String description;
  final String? shortDescription;
  final String image;
  final String imageThumb;
  final String imagePageHeader;
  final String parentId;
  final String? parent;
  final String webUrl;
  final List<CategoryModel>? aChild;

  CategoryModel({
    required this.categoryId,
    required this.type,
    required this.name,
    required this.heading,
    required this.title,
    required this.url,
    required this.description,
    this.shortDescription,
    required this.image,
    required this.imageThumb,
    required this.imagePageHeader,
    required this.parentId,
    this.parent,
    required this.webUrl,
    this.aChild,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['category_id']?.toString() ?? '',
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      heading: json['heading'] ?? '',
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      description: json['description'] ?? '',
      shortDescription: json['short_description'],
      image: json['image'] ?? '',
      imageThumb: json['image_thumb'] ?? '',
      imagePageHeader: json['image_page_header'] ?? '',
      parentId: json['parent_id']?.toString() ?? '0',
      parent: json['parent'],
      webUrl: json['web_url'] ?? '',
      aChild: json['aChild'] != null
          ? (json['aChild'] as List)
              .map((e) => CategoryModel.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'type': type,
      'name': name,
      'heading': heading,
      'title': title,
      'url': url,
      'description': description,
      'short_description': shortDescription,
      'image': image,
      'image_thumb': imageThumb,
      'image_page_header': imagePageHeader,
      'parent_id': parentId,
      'parent': parent,
      'web_url': webUrl,
      'aChild': aChild?.map((e) => e.toJson()).toList(),
    };
  }

  bool get isMenu => type == 'Menu';
  bool get isCategory => type == 'Category';
  bool get hasChildren => aChild != null && aChild!.isNotEmpty;

  // Compatibility getters for UI
  String get id => categoryId;
  String get imageUrl => image.isNotEmpty ? image : imageThumb;
  int get productCount => 0; // Not available from API, default to 0
}
