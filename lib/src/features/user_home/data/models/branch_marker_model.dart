import 'package:motogo_frontend/src/features/user_home/domain/entities/branch_marker_entity.dart';

/// Model for branch marker data from API.
///
/// Maps the backend response from GET /branches/nearby to entity.
class BranchMarkerModel extends BranchMarkerEntity {
  const BranchMarkerModel({
    required super.id,
    required super.name,
    required super.type,
    required super.latitude,
    required super.longitude,
    super.rating,
    super.address,
    super.distanceKm,
    super.typeLabel,
    super.profileImageUrl,
    super.cityName,
    super.departmentName,
    super.brands,
    super.displacementRanges,
  });

  /// Creates a model from JSON response.
  ///
  /// Backend response format:
  /// ```json
  /// {
  ///   "id": "xYz123AbC",
  ///   "name": "Taller Moto Pro",
  ///   "establishment_type": "WORKSHOP",
  ///   "establishment_type_label": "Taller",
  ///   "profile_image_url": "https://...",
  ///   "address": "Calle 123 #45-67",
  ///   "city_name": "Bogotá",
  ///   "department_name": "Bogotá D.C.",
  ///   "latitude": 4.7125,
  ///   "longitude": -74.0698,
  ///   "distance_km": 0.47
  /// }
  /// ```
  factory BranchMarkerModel.fromJson(Map<String, dynamic> json) {
    return BranchMarkerModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: _mapEstablishmentType(json['establishment_type'] as String?),
      typeLabel: json['establishment_type_label'] as String?,
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      address: json['address'] as String?,
      cityName: json['city_name'] as String?,
      departmentName: json['department_name'] as String?,
      distanceKm: json['distance_km'] != null
          ? _parseDouble(json['distance_km'])
          : null,
      profileImageUrl: json['profile_image_url'] as String?,
      rating: json['rating'] != null ? _parseDouble(json['rating']) : null,
      brands: _parseStringList(json['brands']),
      displacementRanges: _parseStringList(json['displacement_ranges']),
    );
  }

  /// Maps backend establishment type to frontend type.
  static String _mapEstablishmentType(String? type) {
    switch (type?.toUpperCase()) {
      case 'WORKSHOP':
        return 'taller';
      case 'STORE':
        return 'tienda';
      case 'WORKSHOP_STORE':
        return 'taller_tienda';
      default:
        return type?.toLowerCase() ?? 'taller';
    }
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Safely parses a list of strings from JSON.
  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return const [];
  }

  /// Converts model to entity.
  BranchMarkerEntity toEntity() {
    return BranchMarkerEntity(
      id: id,
      name: name,
      type: type,
      latitude: latitude,
      longitude: longitude,
      rating: rating,
      address: address,
      distanceKm: distanceKm,
      typeLabel: typeLabel,
      profileImageUrl: profileImageUrl,
      cityName: cityName,
      departmentName: departmentName,
      brands: brands,
      displacementRanges: displacementRanges,
    );
  }
}
