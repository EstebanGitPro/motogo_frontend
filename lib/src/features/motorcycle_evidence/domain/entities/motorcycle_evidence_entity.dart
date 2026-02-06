import 'package:equatable/equatable.dart';

/// Entity representing motorcycle evidence photo.
class MotorcycleEvidenceEntity extends Equatable {
  final String id;
  final String motorcycleId;
  final String imageUrl;
  final String? angle;
  final String? description;
  final DateTime createdAt;

  const MotorcycleEvidenceEntity({
    required this.id,
    required this.motorcycleId,
    required this.imageUrl,
    this.angle,
    this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    motorcycleId,
    imageUrl,
    angle,
    description,
    createdAt,
  ];
}
