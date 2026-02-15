import 'package:motogo_frontend/src/core/utils/json_helpers.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';

/// Data model for branch with JSON serialization.
///
/// Maps to the `branches` table and handles API communication.
class BranchModel extends BranchEntity {
  const BranchModel({
    super.id,
    required super.name,
    required super.establishmentType,
    super.franchiseId,
    super.profileImageUrl,
    super.status = BranchStatus.active,
    super.brands = const [],
    super.displacementRanges = const [],
    required super.location,
  });

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
      displacementRanges: entity.displacementRanges,
      location: entity.location,
    );
  }

  /// Creates a model from JSON map (API response).
  factory BranchModel.fromJson(Map<String, dynamic> json) {
    // Handle nested location data if present
    final loc = json['location'] as Map<String, dynamic>?;

    return BranchModel(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      establishmentType: json['establishment_type'] as String? ?? '',
      franchiseId: json['franchise_id'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      status: json['status'] as String? ?? BranchStatus.active,
      brands: JsonHelpers.parseStringList(json['brands']),
      displacementRanges: JsonHelpers.parseStringList(
        json['displacement_ranges'],
      ),
      location: BranchLocation(
        address: loc?['address'] as String? ?? json['address'] as String,
        cityId: loc?['city_id'] as String? ?? json['city_id'] as String,
        cityName: loc?['city_name'] as String?,
        departmentId:
            loc?['department_id'] as String? ??
            json['department_id'] as String? ??
            '',
        departmentName: loc?['department_name'] as String?,
      ),
    );
  }

  /// Converts model to JSON map for API request.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'establishment_type': establishmentType,
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

    if (displacementRanges.isNotEmpty) {
      map['displacement_ranges'] = displacementRanges;
    }

    // Location as nested object per API contract
    // Coordinates are optional - backend calculates via geocoding if not provided
    map['location'] = {
      'department_id': departmentId,
      'city_id': cityId,
      'address': address,
      if (cityName != null) 'city_name': cityName,
      if (departmentName != null) 'department_name': departmentName,
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
      displacementRanges: displacementRanges,
      location: location,
    );
  }
}
