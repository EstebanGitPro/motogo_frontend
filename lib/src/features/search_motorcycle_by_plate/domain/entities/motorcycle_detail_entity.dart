import 'package:equatable/equatable.dart';

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
/// Includes full reference information (brand, model, category, engine).
/// Used by HU47: Consultar Motocicleta por Placa.
class MotorcycleDetailEntity extends Equatable {
  final String id;
  final String licensePlate;
  final int year;
  final int currentMileage;
  final MotorcycleReferenceInfoEntity reference;

  const MotorcycleDetailEntity({
    required this.id,
    required this.licensePlate,
    required this.year,
    required this.currentMileage,
    required this.reference,
  });

  @override
  List<Object?> get props => [
    id,
    licensePlate,
    year,
    currentMileage,
    reference,
  ];
}
