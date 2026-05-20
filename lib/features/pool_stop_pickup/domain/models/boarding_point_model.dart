class BoardingPoint {
  final int id;
  final String name;
  final String nameAr;
  final String governorate;
  final String city;
  final double latitude;
  final double longitude;
  final bool? isActive;
  final int? sortOrder;
  final String? createdAt;
  final String? updatedAt;

  BoardingPoint({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.governorate,
    required this.city,
    required this.latitude,
    required this.longitude,
    this.isActive,
    this.sortOrder,
    this.createdAt,
    this.updatedAt,
  });

  factory BoardingPoint.fromJson(Map<String, dynamic> json) {
    try {
      return BoardingPoint(
        id: json['id'] is int ? json['id'] : int.parse((json['id'] ?? '0').toString()),
        name: json['name'] ?? '',
        nameAr: json['name_ar'] ?? '',
        governorate: json['governorate'] ?? '',
        city: json['city'] ?? '',
        latitude: (json['latitude'] ?? 0.0).toDouble(),
        longitude: (json['longitude'] ?? 0.0).toDouble(),
        isActive: json['is_active'] is int ? (json['is_active'] == 1) : (json['is_active'] as bool?),
        sortOrder: json['sort_order'] is int ? json['sort_order'] : null,
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
      );
    } catch (e) {
      print('Error parsing BoardingPoint: $e');
      return BoardingPoint(
        id: 0,
        name: '',
        nameAr: '',
        governorate: '',
        city: '',
        latitude: 0.0,
        longitude: 0.0,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'governorate': governorate,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'is_active': isActive,
      'sort_order': sortOrder,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoardingPoint &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
