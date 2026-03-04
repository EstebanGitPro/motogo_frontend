import 'package:equatable/equatable.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/entities/completed_service_item_entity.dart';

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
  final List<CompletedServiceItemEntity> services;
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
    this.services = const [],
    this.branchName,
  });

  /// Whether the service has reached its final state.
  bool get isFinalized => status == 'FINALIZADO';

  /// Whether any items still need to be rated.
  bool get hasUnratedItems => services.any((item) => !item.isRated);

  /// Count of already-rated items.
  int get ratedCount => services.where((item) => item.isRated).length;

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
    services,
    branchName,
  ];
}
