import 'package:equatable/equatable.dart';

/// Entity representing a completed service for a motorcycle.
///
/// Maps to the backend `servicios_realizados` table.
class CompletedServiceEntity extends Equatable {
  final String id;
  final String? diagnosticId;
  final String serviceName;
  final String status;
  final double? quotedPrice;
  final double? finalPrice;
  final String? representativeNotes;
  final DateTime date;

  const CompletedServiceEntity({
    required this.id,
    this.diagnosticId,
    required this.serviceName,
    required this.status,
    this.quotedPrice,
    this.finalPrice,
    this.representativeNotes,
    required this.date,
  });

  @override
  List<Object?> get props => [
    id,
    diagnosticId,
    serviceName,
    status,
    quotedPrice,
    finalPrice,
    representativeNotes,
    date,
  ];
}
