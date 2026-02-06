import 'package:motogo_frontend/src/features/motorcycle_evidence/domain/entities/motorcycle_evidence_entity.dart';

/// Model for motorcycle evidence API response.
class MotorcycleEvidenceModel {
  final String id;
  final String motorcycleId;
  final String imageUrl;
  final String? angle;
  final String? description;
  final String createdAt;

  const MotorcycleEvidenceModel({
    required this.id,
    required this.motorcycleId,
    required this.imageUrl,
    this.angle,
    this.description,
    required this.createdAt,
  });

  factory MotorcycleEvidenceModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final source = data ?? json;

    return MotorcycleEvidenceModel(
      id: source['id'] as String? ?? '',
      motorcycleId: source['motorcycle_id'] as String? ?? '',
      imageUrl: source['image_url'] as String? ?? '',
      angle: source['angle'] as String?,
      description: source['description'] as String?,
      createdAt: source['created_at'] as String? ?? '',
    );
  }

  /// Factory for parsing a single item from a list response (no wrapper).
  factory MotorcycleEvidenceModel.fromDataJson(Map<String, dynamic> json) {
    return MotorcycleEvidenceModel(
      id: json['id'] as String? ?? '',
      motorcycleId: json['motorcycle_id'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      angle: json['angle'] as String?,
      description: json['description'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  MotorcycleEvidenceEntity toEntity() {
    return MotorcycleEvidenceEntity(
      id: id,
      motorcycleId: motorcycleId,
      imageUrl: imageUrl,
      angle: angle,
      description: description,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }
}
