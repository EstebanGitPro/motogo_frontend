import 'package:motogo_frontend/src/features/diagnostic/domain/entity/diagnostic_entity.dart';

/// Model for a single evidence item in a diagnostic response.
class DiagnosticEvidenceModel {
  final String id;
  final String imageUrl;
  final String? description;
  final String createdAt;

  const DiagnosticEvidenceModel({
    required this.id,
    required this.imageUrl,
    this.description,
    required this.createdAt,
  });

  factory DiagnosticEvidenceModel.fromJson(Map<String, dynamic> json) {
    return DiagnosticEvidenceModel(
      id: json['id'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      description: json['description'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  DiagnosticEvidenceEntity toEntity() {
    return DiagnosticEvidenceEntity(
      id: id,
      imageUrl: imageUrl,
      description: description,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }
}

/// Model for diagnostic API responses.
class DiagnosticModel {
  final String id;
  final String motorcycleId;
  final String? branchId;
  final String? branchName;
  final String problemDescription;
  final String? possibleSolution;
  final String date;
  final List<DiagnosticEvidenceModel> evidence;

  const DiagnosticModel({
    required this.id,
    required this.motorcycleId,
    this.branchId,
    this.branchName,
    required this.problemDescription,
    this.possibleSolution,
    required this.date,
    this.evidence = const [],
  });

  factory DiagnosticModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return DiagnosticModel._fromMap(data ?? json);
  }

  /// Factory for parsing a single item from a list response (no wrapper).
  factory DiagnosticModel.fromDataJson(Map<String, dynamic> json) {
    return DiagnosticModel._fromMap(json);
  }

  /// Shared parsing logic for both [fromJson] and [fromDataJson].
  factory DiagnosticModel._fromMap(Map<String, dynamic> source) {
    return DiagnosticModel(
      id: source['id'] as String? ?? '',
      motorcycleId: source['motorcycle_id'] as String? ?? '',
      branchId: source['branch_id'] as String?,
      branchName: source['branch_name'] as String?,
      problemDescription: source['problem_description'] as String? ?? '',
      possibleSolution: source['possible_solution'] as String?,
      date: source['date'] as String? ?? '',
      evidence: _parseEvidence(source['evidence']),
    );
  }

  static List<DiagnosticEvidenceModel> _parseEvidence(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(DiagnosticEvidenceModel.fromJson)
        .toList();
  }

  DiagnosticEntity toEntity() {
    return DiagnosticEntity(
      id: id,
      motorcycleId: motorcycleId,
      branchId: branchId,
      branchName: branchName,
      problemDescription: problemDescription,
      possibleSolution: possibleSolution,
      date: DateTime.tryParse(date) ?? DateTime.now(),
      evidence: evidence.map((e) => e.toEntity()).toList(),
    );
  }

  /// Converts the model to a map for POST/PUT requests.
  Map<String, dynamic> toMap() {
    return {
      'problem_description': problemDescription,
      if (branchId != null) 'branch_id': branchId,
    };
  }
}
