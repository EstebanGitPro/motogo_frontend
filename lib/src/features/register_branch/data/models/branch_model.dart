import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';

/// Data model for branch with JSON serialization.
///
/// Maps to the `branches` table and handles API communication.
class BranchModel extends BranchEntity {
  final String? id;
  final String name;
  final String establishmentType;
  final String? franchiseId;
  final String? profileImageUrl;
  final String status;
  final List<String> brands;
  final String address;
  final String cityId;
  final String? cityName;
  final String? departmentId;
  final String? departmentName;
  final double? latitude;
  final double? longitude;

  const BranchModel({
    this.id,
    required this.name,
    required this.establishmentType,
    this.franchiseId,
    this.profileImageUrl,
    this.status = 'ACTIVE',
    this.brands = const [],
    required this.address,
    required this.cityId,
    this.cityName,
    this.departmentId,
    this.departmentName,
    this.latitude,
    this.longitude,
  }) : super(
         id: id,
         name: name,
         establishmentType: establishmentType,
         franchiseId: franchiseId,
         profileImageUrl: profileImageUrl,
         status: status,
         brands: brands,
         address: address,
         cityId: cityId,
         cityName: cityName,
         departmentId: departmentId,
         departmentName: departmentName,
         latitude: latitude,
         longitude: longitude,
       );

  /// Creates a model from domain entity.
  factory BranchModel.fromEntity(BranchEntity entity) {
    return BranchModel(
      id: entity.id,
      name: entity.name,
      establishmentType: entity.establishmentType,
      franchiseId: entity.franchiseId,
      profileImageUrl: entity.profileImageUrl,
      status: entity.status,
      brands: entity.brands,
      address: entity.address,
      cityId: entity.cityId,
      cityName: entity.cityName,
      departmentId: entity.departmentId,
      departmentName: entity.departmentName,
      latitude: entity.latitude,
      longitude: entity.longitude,
    );
  }

  /// Creates a model from JSON map (API response).
  factory BranchModel.fromJson(Map<String, dynamic> json) {
    // Handle nested location data if present
    final location = json['location'] as Map<String, dynamic>?;

    return BranchModel(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      establishmentType: json['establishment_type'] as String? ?? 'WORKSHOP',
      franchiseId: json['franchise_id'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      brands: _parseBrands(json['brands']),
      address: location?['address'] as String? ?? json['address'] as String,
      cityId: location?['city_id'] as String? ?? json['city_id'] as String,
      cityName: location?['city_name'] as String?,
      departmentId: location?['department_id'] as String?,
      departmentName: location?['department_name'] as String?,
      latitude: _parseDouble(location?['latitude'] ?? json['latitude']),
      longitude: _parseDouble(location?['longitude'] ?? json['longitude']),
    );
  }

  /// Converts model to JSON map for API request.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'establishment_type': establishmentType,
      'status': status,
    };

    if (franchiseId != null) {
      map['franchise_id'] = franchiseId;
    }

    if (profileImageUrl != null) {
      map['profile_image_url'] = profileImageUrl;
    }

    if (brands.isNotEmpty) {
      map['brands'] = brands;
    }

    // Location as nested object
    map['location'] = {
      'address': address,
      'city_id': cityId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };

    return map;
  }

  /// Converts model to domain entity.
  BranchEntity toEntity() {
    return BranchEntity(
      id: id,
      name: name,
      establishmentType: establishmentType,
      franchiseId: franchiseId,
      profileImageUrl: profileImageUrl,
      status: status,
      brands: brands,
      address: address,
      cityId: cityId,
      cityName: cityName,
      departmentId: departmentId,
      departmentName: departmentName,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Helper to parse brands from various formats.
  static List<String> _parseBrands(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  /// Helper to safely parse double values.
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
