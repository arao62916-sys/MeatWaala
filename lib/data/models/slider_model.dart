class SliderModel {
  final String sliderId;
  final String orderBy;
  final String name;
  final String content;
  final String image;
  final String status;

  SliderModel({
    required this.sliderId,
    required this.orderBy,
    required this.name,
    required this.content,
    required this.image,
    required this.status,
  });

  factory SliderModel.fromJson(Map<String, dynamic> json) {
    return SliderModel(
      sliderId: json['slider_id']?.toString() ?? '',
      orderBy: json['order_by']?.toString() ?? '0',
      name: json['name']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }

  bool get isEnabled => status == 'Enabled';
}
