import 'package:equatable/equatable.dart';

/// Entity representing a motorcycle registered by a user.
///
/// Part of the domain layer for the register_motorcycle feature.
class MotorcycleEntity extends Equatable {
  final String? id;
  final String licensePlate;
  final String? referenceId;
  final int? year;
  final int? currentMileage;
  final String? ownerNotes;
  final String? profileImageUrl;

  const MotorcycleEntity({
    this.id,
    required this.licensePlate,
    this.referenceId,
    this.year,
    this.currentMileage,
    this.ownerNotes,
    this.profileImageUrl,
  });

  @override
  List<Object?> get props => [
    id,
    licensePlate,
    referenceId,
    year,
    currentMileage,
    ownerNotes,
    profileImageUrl,
  ];

  /// Creates a copy of this entity with optional field overrides.
  MotorcycleEntity copyWith({
    String? id,
    String? licensePlate,
    String? referenceId,
    int? year,
    int? currentMileage,
    String? ownerNotes,
    String? profileImageUrl,
  }) {
    return MotorcycleEntity(
      id: id ?? this.id,
      licensePlate: licensePlate ?? this.licensePlate,
      referenceId: referenceId ?? this.referenceId,
      year: year ?? this.year,
      currentMileage: currentMileage ?? this.currentMileage,
      ownerNotes: ownerNotes ?? this.ownerNotes,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
