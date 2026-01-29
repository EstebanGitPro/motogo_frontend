import 'package:motogo_frontend/src/features/register_motorcycle/domain/entities/motorcycle_reference_entity.dart';

/// Model for motorcycle reference API responses.
class MotorcycleReferenceModel {
  final String id;
  final String brandId;
  final String brandName;
  final String model;
  final String? category;
  final int? engineDisplacementCc;

  const MotorcycleReferenceModel({
    required this.id,
    required this.brandId,
    required this.brandName,
    required this.model,
    this.category,
    this.engineDisplacementCc,
  });

  factory MotorcycleReferenceModel.fromJson(Map<String, dynamic> json) {
    return MotorcycleReferenceModel(
      id: json['id'] as String? ?? '',
      brandId: json['brand_id'] as String? ?? '',
      brandName: json['brand_name'] as String? ?? '',
      model: json['model'] as String? ?? '',
      category: json['category'] as String?,
      engineDisplacementCc: json['engine_displacement_cc'] as int?,
    );
  }

  MotorcycleReferenceEntity toEntity() {
    return MotorcycleReferenceEntity(
      id: id,
      brandId: brandId,
      brandName: brandName,
      model: model,
      category: category,
      engineDisplacementCc: engineDisplacementCc,
    );
  }
}
