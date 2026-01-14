import 'package:motogo_frontend/src/core/catalogs/domain/entities/branch_type_entity.dart';

/// Data model for branch type with JSON serialization.
class BranchTypeModel extends BranchTypeEntity {
  const BranchTypeModel({required super.code, required super.label});

  /// Creates a model from JSON map.
  factory BranchTypeModel.fromJson(Map<String, dynamic> json) {
    return BranchTypeModel(
      code: json['code'] as String? ?? '',
      label: json['label'] as String? ?? '',
    );
  }

  /// Parses a list of branch types from API response.
  /// Expected format: {"types": [...]}
  static List<BranchTypeModel> fromJsonList(Map<String, dynamic> response) {
    final types = response['types'] as List<dynamic>?;
    if (types == null) return [];

    return types
        .map((item) => BranchTypeModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Converts to entity.
  BranchTypeEntity toEntity() {
    return BranchTypeEntity(code: code, label: label);
  }
}
