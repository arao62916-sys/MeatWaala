/// Category model matching API response
class CategoryModel {
  final String categoryId;
  final String name;
  final String type;
  final String? heading;
  final String? title;
  final String? url;
  final String? description;
  final String? shortDescription;
  final String? image;
  final String? imageThumb;
  final String? imagePageHeader;
  final String? parentId;
  final String? parent;
  final String? webUrl;
  final List<CategoryModel> aChild;

  CategoryModel({
    required this.categoryId,
    required this.name,
    required this.type,
    this.heading,
    this.title,
    this.url,
    this.description,
    this.shortDescription,
    this.image,
    this.imageThumb,
    this.imagePageHeader,
    this.parentId,
    this.parent,
    this.webUrl,
    List<CategoryModel>? aChild,
  }) : aChild = aChild ?? const [];

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['category_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      heading: json['heading']?.toString(),
      title: json['title']?.toString(),
      url: json['url']?.toString(),
      description: json['description']?.toString(),
      shortDescription: json['short_description']?.toString(),
      image: json['image']?.toString(),
      imageThumb: json['image_thumb']?.toString(),
      imagePageHeader: json['image_page_header']?.toString(),
      parentId: json['parent_id']?.toString(),
      parent: json['parent']?.toString(),
      webUrl: json['web_url']?.toString(),
      aChild: (json['aChild'] is List)
          ? (json['aChild'] as List)
              .map((e) => CategoryModel.fromJson(e))
              .toList()
          : const [],
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
      'aChild': aChild.map((e) => e.toJson()).toList(),
    };
  }

  bool get isMenu => type == 'Menu';
  bool get isCategory => type == 'Category';
  bool get hasChildren => aChild.isNotEmpty;

  String get id => categoryId;
  String get imageUrl =>
      (image != null && image!.isNotEmpty) ? image! : (imageThumb ?? '');
  int get productCount => 0;
}
