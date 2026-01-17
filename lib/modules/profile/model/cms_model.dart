/// CMS Content Model
/// Represents the response from CMS API endpoints
class CmsModel {
  final String cmsId;
  final String name;
  final String url;
  final String appContent;

  CmsModel({
    required this.cmsId,
    required this.name,
    required this.url,
    required this.appContent,
  });

  /// Parse CMS data from API response
  factory CmsModel.fromJson(Map<String, dynamic> json) {
    return CmsModel(
      cmsId: json['cms_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      appContent: json['app_content']?.toString() ?? '',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'cms_id': cmsId,
      'name': name,
      'url': url,
      'app_content': appContent,
    };
  }

  /// Get formatted content (replace \r\n with proper line breaks)
  String get formattedContent {
    return appContent.replaceAll(r'\r\n', '\n').trim();
  }

  @override
  String toString() {
    return 'CmsModel(id: $cmsId, name: $name, url: $url)';
  }
}
