import 'package:equatable/equatable.dart';
import 'package:motogo_frontend/src/features/diagnostic/domain/entity/diagnostic_entity.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/domain/entities/motorcycle_evidence_entity.dart';

/// Information about a motorcycle's reference (brand, model, etc).
///
/// Part of the domain layer for search motorcycle by plate feature.
class MotorcycleReferenceInfoEntity extends Equatable {
  final String brandName;
  final String model;
  final String category;
  final int engineDisplacementCc;

  const MotorcycleReferenceInfoEntity({
    required this.brandName,
    required this.model,
    required this.category,
    required this.engineDisplacementCc,
  });

  @override
  List<Object?> get props => [brandName, model, category, engineDisplacementCc];
}

/// Entity representing detailed motorcycle information from plate lookup.
///
/// Includes full reference information (brand, model, category, engine)
/// and diagnostics history for workshop view.
/// Used by HU47: Consultar Motocicleta por Placa.
class MotorcycleDetailEntity extends Equatable {
  final String id;
  final String licensePlate;
  final int year;
  final int currentMileage;
  final String? profileImageUrl;
  final MotorcycleReferenceInfoEntity reference;
  final List<DiagnosticEntity> diagnostics;
  final List<MotorcycleEvidenceEntity> evidence;

  const MotorcycleDetailEntity({
    required this.id,
    required this.licensePlate,
    required this.year,
    required this.currentMileage,
    this.profileImageUrl,
    required this.reference,
    this.diagnostics = const [],
    this.evidence = const [],
  });

  @override
  List<Object?> get props => [
    id,
    licensePlate,
    year,
    currentMileage,
    profileImageUrl,
    reference,
    diagnostics,
    evidence,
  ];
}
