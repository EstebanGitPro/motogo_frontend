import 'package:motogo_frontend/src/features/diagnostic/data/model/diagnostic_model.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/data/models/motorcycle_evidence_model.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/entities/motorcycle_detail_entity.dart';

/// Model for motorcycle reference info from API response.
class MotorcycleReferenceInfoModel {
  final String brandName;
  final String model;
  final String category;
  final int engineDisplacementCc;

  const MotorcycleReferenceInfoModel({
    required this.brandName,
    required this.model,
    required this.category,
    required this.engineDisplacementCc,
  });

  factory MotorcycleReferenceInfoModel.fromJson(Map<String, dynamic> json) {
    return MotorcycleReferenceInfoModel(
      brandName: json['brand_name']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      engineDisplacementCc:
          (json['engine_displacement_cc'] as num?)?.toInt() ?? 0,
    );
  }

  MotorcycleReferenceInfoEntity toEntity() {
    return MotorcycleReferenceInfoEntity(
      brandName: brandName,
      model: model,
      category: category,
      engineDisplacementCc: engineDisplacementCc,
    );
  }
}

/// Data model for motorcycle detail from plate lookup.
///
/// Handles JSON conversion for the GET /motorcycles/lookup endpoint (HU47).
/// Includes diagnostics array with evidence for workshop view.
class MotorcycleDetailModel {
  final String id;
  final String licensePlate;
  final int year;
  final int currentMileage;
  final String? profileImageUrl;
  final MotorcycleReferenceInfoModel reference;
  final List<DiagnosticModel> diagnostics;
  final List<MotorcycleEvidenceModel> evidence;

  const MotorcycleDetailModel({
    required this.id,
    required this.licensePlate,
    required this.year,
    required this.currentMileage,
    this.profileImageUrl,
    required this.reference,
    this.diagnostics = const [],
    this.evidence = const [],
  });

  /// Creates a model from JSON response.
  factory MotorcycleDetailModel.fromJson(Map<String, dynamic> json) {
    return MotorcycleDetailModel(
      id: json['id']?.toString() ?? '',
      licensePlate: json['license_plate']?.toString() ?? '',
      year: (json['year'] as num?)?.toInt() ?? 0,
      currentMileage: (json['current_mileage'] as num?)?.toInt() ?? 0,
      profileImageUrl: json['profile_image_url'] as String?,
      reference: MotorcycleReferenceInfoModel.fromJson(
        json['reference'] as Map<String, dynamic>? ?? {},
      ),
      diagnostics: _parseDiagnostics(json['diagnostics']),
      evidence: _parseEvidence(json['evidence']),
    );
  }

  static List<DiagnosticModel> _parseDiagnostics(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(DiagnosticModel.fromDataJson)
        .toList();
  }

  static List<MotorcycleEvidenceModel> _parseEvidence(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(MotorcycleEvidenceModel.fromDataJson)
        .toList();
  }

  /// Converts the model to a domain entity.
  MotorcycleDetailEntity toEntity() {
    return MotorcycleDetailEntity(
      id: id,
      licensePlate: licensePlate,
      year: year,
      currentMileage: currentMileage,
      profileImageUrl: profileImageUrl,
      reference: reference.toEntity(),
      diagnostics: diagnostics.map((d) => d.toEntity()).toList(),
      evidence: evidence.map((e) => e.toEntity()).toList(),
    );
  }
}
