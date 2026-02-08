import 'package:equatable/equatable.dart';

/// Represents a single evidence item attached to a diagnostic.
class DiagnosticEvidenceEntity extends Equatable {
  final String id;
  final String imageUrl;
  final DateTime createdAt;

  const DiagnosticEvidenceEntity({
    required this.id,
    required this.imageUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, imageUrl, createdAt];
}

/// Entity representing a motorcycle diagnostic request.
class DiagnosticEntity extends Equatable {
  final String id;
  final String motorcycleId;
  final String? branchId;
  final String problemDescription;
  final DateTime date;
  final bool sentViaWhatsapp;
  final List<DiagnosticEvidenceEntity> evidence;

  const DiagnosticEntity({
    required this.id,
    required this.motorcycleId,
    this.branchId,
    required this.problemDescription,
    required this.date,
    this.sentViaWhatsapp = false,
    this.evidence = const [],
  });

  @override
  List<Object?> get props => [
    id,
    motorcycleId,
    branchId,
    problemDescription,
    date,
    sentViaWhatsapp,
    evidence,
  ];
}
