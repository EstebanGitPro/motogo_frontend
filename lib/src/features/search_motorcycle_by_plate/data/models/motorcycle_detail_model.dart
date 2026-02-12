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

/// Model for permitted branch info from API response.
class PermittedBranchInfoModel {
  final String id;
  final String name;

  const PermittedBranchInfoModel({required this.id, required this.name});

  factory PermittedBranchInfoModel.fromJson(Map<String, dynamic> json) {
    return PermittedBranchInfoModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  PermittedBranchEntity toEntity() {
    return PermittedBranchEntity(id: id, name: name);
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
  final List<PermittedBranchInfoModel> permittedBranches;

  const MotorcycleDetailModel({
    required this.id,
    required this.licensePlate,
    required this.year,
    required this.currentMileage,
    this.profileImageUrl,
    required this.reference,
    this.diagnostics = const [],
    this.evidence = const [],
    this.permittedBranches = const [],
  });

  /// Creates a model from JSON response.
  ///
  /// Evidence is parsed from the top-level 'evidence' field (motorcycle_evidence
  /// table, HU16-19). Falls back to extracting from nested diagnostics for
  /// backwards compatibility.
  factory MotorcycleDetailModel.fromJson(Map<String, dynamic> json) {
    final diagnostics = _parseDiagnostics(json['diagnostics']);

    // Parse motorcycle evidence from the top-level 'evidence' field (HU16-19)
    // Falls back to extracting from diagnostics for backwards compatibility
    final topLevelEvidence = _parseEvidence(json['evidence']);
    final evidence = topLevelEvidence.isNotEmpty
        ? topLevelEvidence
        : _extractEvidenceFromDiagnostics(json['diagnostics']);

    return MotorcycleDetailModel(
      id: json['id']?.toString() ?? '',
      licensePlate: json['license_plate']?.toString() ?? '',
      year: (json['year'] as num?)?.toInt() ?? 0,
      currentMileage: (json['current_mileage'] as num?)?.toInt() ?? 0,
      profileImageUrl: json['profile_image_url'] as String?,
      reference: MotorcycleReferenceInfoModel.fromJson(
        json['reference'] as Map<String, dynamic>? ?? {},
      ),
      diagnostics: diagnostics,
      evidence: evidence,
      permittedBranches: _parsePermittedBranches(json['permitted_branches']),
    );
  }

  static List<DiagnosticModel> _parseDiagnostics(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(DiagnosticModel.fromDataJson)
        .toList();
  }

  static List<PermittedBranchInfoModel> _parsePermittedBranches(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(PermittedBranchInfoModel.fromJson)
        .toList();
  }

  static List<MotorcycleEvidenceModel> _parseEvidence(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(MotorcycleEvidenceModel.fromDataJson)
        .toList();
  }

  /// Extracts evidence from all diagnostics in the response.
  ///
  /// The backend nests evidence inside each diagnostic (diagnostics[i].evidence).
  /// This method flattens all evidence from all diagnostics into a single list.
  static List<MotorcycleEvidenceModel> _extractEvidenceFromDiagnostics(
    dynamic rawDiagnostics,
  ) {
    if (rawDiagnostics is! List) return const [];

    final allEvidence = <MotorcycleEvidenceModel>[];
    for (final diag in rawDiagnostics) {
      if (diag is! Map<String, dynamic>) continue;
      final evidenceList = diag['evidence'];
      if (evidenceList is! List) continue;
      for (final e in evidenceList) {
        if (e is! Map<String, dynamic>) continue;
        allEvidence.add(
          MotorcycleEvidenceModel(
            id: e['id'] as String? ?? '',
            motorcycleId: diag['motorcycle_id'] as String? ?? '',
            imageUrl: e['image_url'] as String? ?? '',
            description: e['description'] as String?,
            createdAt: e['created_at'] as String? ?? '',
          ),
        );
      }
    }
    return allEvidence;
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
      permittedBranches: permittedBranches.map((b) => b.toEntity()).toList(),
    );
  }
}
