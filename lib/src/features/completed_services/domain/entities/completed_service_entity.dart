import 'package:equatable/equatable.dart';

/// Entity representing a completed service record.
///
/// Used to display the service history for a motorcycle.
class CompletedServiceEntity extends Equatable {
  final String id;
  final String branchId;
  final String motorcycleId;
  final String? diagnosticId;
  final String status;
  final DateTime requestDate;
  final double? quotedPrice;
  final double? finalPrice;
  final String? representativeNotes;
  final List<String> serviceIds;
  final List<String> serviceNames;
  final String? branchName;

  const CompletedServiceEntity({
    required this.id,
    required this.branchId,
    required this.motorcycleId,
    this.diagnosticId,
    required this.status,
    required this.requestDate,
    this.quotedPrice,
    this.finalPrice,
    this.representativeNotes,
    this.serviceIds = const [],
    this.serviceNames = const [],
    this.branchName,
  });

  @override
  List<Object?> get props => [
    id,
    branchId,
    motorcycleId,
    diagnosticId,
    status,
    requestDate,
    quotedPrice,
    finalPrice,
    representativeNotes,
    serviceIds,
    serviceNames,
    branchName,
  ];
}
