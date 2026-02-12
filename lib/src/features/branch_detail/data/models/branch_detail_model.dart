import 'package:motogo_frontend/src/features/branch_detail/domain/entities/branch_detail_entity.dart';

/// Model for parsing branch detail JSON from the API.
///
/// Maps to the GET /branches/{id} endpoint response.
class BranchDetailModel extends BranchDetailEntity {
  const BranchDetailModel({
    required super.id,
    required super.name,
    required super.type,
    super.typeLabel,
    super.profileImageUrl,
    super.address,
    super.cityName,
    super.departmentName,
    super.phoneNumber,
    required super.latitude,
    required super.longitude,
  });

  /// Creates a model from JSON API response.
  ///
  /// Expected format from GET /branches/{id}:
  /// ```json
  /// {
  ///   "id": "xYz123AbC",
  ///   "name": "MotoTech Garage",
  ///   "establishment_type": "WORKSHOP",
  ///   "establishment_type_label": "Taller",
  ///   "profile_image_url": "https://...",
  ///   "location": {
  ///     "address": "Av. Principal 123",
  ///     "city_name": "Ciudad Moto",
  ///     "department_name": "Departamento",
  ///     "latitude": 4.7125,
  ///     "longitude": -74.0698
  ///   }
  /// }
  /// ```
  factory BranchDetailModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;

    return BranchDetailModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: _mapEstablishmentType(json['establishment_type'] as String?),
      typeLabel: json['establishment_type_label'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      address: location?['address'] as String?,
      cityName: location?['city_name'] as String?,
      departmentName: location?['department_name'] as String?,
      phoneNumber: json['contact_phone'] as String?,
      latitude: _parseDouble(location?['latitude']),
      longitude: _parseDouble(location?['longitude']),
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

  /// Safely parses a double from dynamic value.
  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Converts to domain entity.
  BranchDetailEntity toEntity() {
    return BranchDetailEntity(
      id: id,
      name: name,
      type: type,
      typeLabel: typeLabel,
      profileImageUrl: profileImageUrl,
      address: address,
      cityName: cityName,
      departmentName: departmentName,
      phoneNumber: phoneNumber,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
