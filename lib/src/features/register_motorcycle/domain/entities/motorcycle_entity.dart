import 'package:equatable/equatable.dart';

/// Entity representing a motorcycle registered by a user.
///
/// Part of the domain layer for the register_motorcycle feature.
class MotorcycleEntity extends Equatable {
  final String? id;
  final String licensePlate;
  final int? year;
  final int? currentMileage;
  final String? ownerNotes;

  const MotorcycleEntity({
    this.id,
    required this.licensePlate,
    this.year,
    this.currentMileage,
    this.ownerNotes,
  });

  @override
  List<Object?> get props => [
    id,
    licensePlate,
    year,
    currentMileage,
    ownerNotes,
  ];

  /// Creates a copy of this entity with optional field overrides.
  MotorcycleEntity copyWith({
    String? id,
    String? licensePlate,
    int? year,
    int? currentMileage,
    String? ownerNotes,
  }) {
    return MotorcycleEntity(
      id: id ?? this.id,
      licensePlate: licensePlate ?? this.licensePlate,
      year: year ?? this.year,
      currentMileage: currentMileage ?? this.currentMileage,
      ownerNotes: ownerNotes ?? this.ownerNotes,
    );
  }
}
