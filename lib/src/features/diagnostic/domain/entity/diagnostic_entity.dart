import 'package:equatable/equatable.dart';

/// Represents a single evidence item attached to a diagnostic.
class DiagnosticEvidenceEntity extends Equatable {
  final String id;
  final String imageUrl;
  final String? description;
  final DateTime createdAt;

  const DiagnosticEvidenceEntity({
    required this.id,
    required this.imageUrl,
    this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, imageUrl, description, createdAt];
}

/// Entity representing a motorcycle diagnostic request.
class DiagnosticEntity extends Equatable {
  final String id;
  final String motorcycleId;
  final String? branchId;
  final String problemDescription;
  final String? possibleSolution;
  final DateTime date;
  final List<DiagnosticEvidenceEntity> evidence;

  const DiagnosticEntity({
    required this.id,
    required this.motorcycleId,
    this.branchId,
    required this.problemDescription,
    this.possibleSolution,
    required this.date,
    this.evidence = const [],
  });

  @override
  List<Object?> get props => [
    id,
    motorcycleId,
    branchId,
    problemDescription,
    possibleSolution,
    date,
    evidence,
  ];
}
