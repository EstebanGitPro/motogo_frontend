import 'package:motogo_frontend/src/features/register_franchise/domain/entities/franchise_entity.dart';

/// Data model for franchise with JSON serialization.
class FranchiseModel extends FranchiseEntity {
  final int? branchCount;

  const FranchiseModel({
    super.id,
    required super.name,
    super.description,
    super.branchIds,
    this.branchCount,
  });

  /// Creates a [FranchiseModel] from a JSON map.
  factory FranchiseModel.fromJson(Map<String, dynamic> json) {
    return FranchiseModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      branchIds:
          (json['branch_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      branchCount: json['branch_count'] as int?,
    );
  }

  /// Converts the model to a JSON map for API requests.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null && description!.isNotEmpty)
        'description': description,
      'branch_ids': branchIds,
    };
  }

  /// Creates a [FranchiseModel] from a [FranchiseEntity].
  factory FranchiseModel.fromEntity(FranchiseEntity entity) {
    return FranchiseModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      branchIds: entity.branchIds,
    );
  }
}
