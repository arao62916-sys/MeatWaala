/// Area Model for delivery area selection
class AreaModel {
  final String areaId;
  final String name;
  final String pin;
  final String charge;

  AreaModel({
    required this.areaId,
    required this.name,
    required this.pin,
    required this.charge,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      areaId: json['area_id']?.toString() ?? '',
      name: json['name'] ?? '',
      pin: json['pin']?.toString() ?? '',
      charge: json['charge']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'area_id': areaId,
      'name': name,
      'pin': pin,
      'charge': charge,
    };
  }

  /// Get delivery charge as double
  double get deliveryCharge => double.tryParse(charge) ?? 0.0;

  @override
  String toString() {
    return 'AreaModel(areaId: $areaId, name: $name, pin: $pin, charge: $charge)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AreaModel && other.areaId == areaId;
  }

  @override
  int get hashCode => areaId.hashCode;
}
