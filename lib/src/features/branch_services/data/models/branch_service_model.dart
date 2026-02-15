import 'package:motogo_frontend/src/features/branch_services/domain/entities/branch_service_entity.dart';

/// Model for parsing branch service JSON from the API.
///
/// Handles JSON deserialization for services associated with a branch.
class BranchServiceModel extends BranchServiceEntity {
  const BranchServiceModel({
    required super.id,
    required super.name,
    required super.description,
    required super.serviceType,
    super.addedAt,
    super.active,
    super.averageRating,
    super.totalReviews,
  });

  /// Creates a BranchServiceModel from JSON map.
  ///
  /// Expected JSON format:
  /// ```json
  /// {
  ///   "id": "abc123",
  ///   "name": "Cambio de aceite",
  ///   "description": "Cambio completo de aceite de motor",
  ///   "service_type": "Mantenimiento",
  ///   "added_at": "2026-01-15T10:30:00-05:00",
  ///   "active": true,
  ///   "average_rating": 4.8,
  ///   "total_reviews": 120
  /// }
  /// ```
  factory BranchServiceModel.fromJson(Map<String, dynamic> json) {
    DateTime? addedAt;
    if (json['added_at'] != null) {
      addedAt = DateTime.tryParse(json['added_at'] as String);
    }

    double? averageRating;
    final rawRating = json['average_rating'];
    if (rawRating is num) {
      averageRating = rawRating.toDouble();
    }

    return BranchServiceModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      serviceType: json['service_type'] as String? ?? '',
      addedAt: addedAt,
      active: json['active'] as bool? ?? true,
      averageRating: averageRating,
      totalReviews: json['total_reviews'] as int? ?? 0,
    );
  }

  /// Converts to BranchServiceEntity for domain layer use.
  BranchServiceEntity toEntity() {
    return BranchServiceEntity(
      id: id,
      name: name,
      description: description,
      serviceType: serviceType,
      addedAt: addedAt,
      active: active,
      averageRating: averageRating,
      totalReviews: totalReviews,
    );
  }
}
