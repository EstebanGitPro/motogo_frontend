part of 'search_motorcycle_bloc.dart';

/// Events for the SearchMotorcycle BLoC.
abstract class SearchMotorcycleEvent extends Equatable {
  const SearchMotorcycleEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when user submits a plate search.
class SearchByPlate extends SearchMotorcycleEvent {
  final String plate;

  const SearchByPlate(this.plate);

  @override
  List<Object?> get props => [plate];
}

/// Event to clear search results and return to initial state.
class ClearSearch extends SearchMotorcycleEvent {
  const ClearSearch();
}

/// Event to set the diagnostic solution (workshop representative).
class SetDiagnosticSolution extends SearchMotorcycleEvent {
  final String diagnosticId;
  final String solution;

  const SetDiagnosticSolution({
    required this.diagnosticId,
    required this.solution,
  });

  @override
  List<Object?> get props => [diagnosticId, solution];
}

/// Event to register a completed service for the found motorcycle.
class RegisterCompletedService extends SearchMotorcycleEvent {
  final String branchId;
  final String motorcycleId;
  final List<String> serviceIds;
  final double? quotedPrice;
  final double? finalPrice;
  final String? representativeNotes;

  const RegisterCompletedService({
    required this.branchId,
    required this.motorcycleId,
    required this.serviceIds,
    this.quotedPrice,
    this.finalPrice,
    this.representativeNotes,
  });

  @override
  List<Object?> get props => [
    branchId,
    motorcycleId,
    serviceIds,
    quotedPrice,
    finalPrice,
    representativeNotes,
  ];
}

/// Event to fetch the service history for a motorcycle.
class FetchServiceHistory extends SearchMotorcycleEvent {
  final String motorcycleId;
  final List<String> branchIds;

  const FetchServiceHistory({
    required this.motorcycleId,
    required this.branchIds,
  });

  @override
  List<Object?> get props => [motorcycleId, branchIds];
}

/// Event to update the status of a completed service.
class UpdateServiceStatus extends SearchMotorcycleEvent {
  final String serviceId;
  final String motorcycleId;
  final String newStatus;
  final double? finalPrice;

  const UpdateServiceStatus({
    required this.serviceId,
    required this.motorcycleId,
    required this.newStatus,
    this.finalPrice,
  });

  @override
  List<Object?> get props => [serviceId, motorcycleId, newStatus, finalPrice];
}

/// Event to update the details of a completed service (HU75).
class UpdateServiceDetails extends SearchMotorcycleEvent {
  final String serviceId;
  final String motorcycleId;
  final double? quotedPrice;
  final double? finalPrice;
  final String? representativeNotes;

  const UpdateServiceDetails({
    required this.serviceId,
    required this.motorcycleId,
    this.quotedPrice,
    this.finalPrice,
    this.representativeNotes,
  });

  @override
  List<Object?> get props => [
    serviceId,
    motorcycleId,
    quotedPrice,
    finalPrice,
    representativeNotes,
  ];
}

/// Event to fetch the transition history of a completed service.
class FetchServiceTransitions extends SearchMotorcycleEvent {
  final String serviceId;

  const FetchServiceTransitions({required this.serviceId});

  @override
  List<Object?> get props => [serviceId];
}

/// Event to delete a completed service (HU65).
class DeleteCompletedService extends SearchMotorcycleEvent {
  final String serviceId;
  final String motorcycleId;

  const DeleteCompletedService({
    required this.serviceId,
    required this.motorcycleId,
  });

  @override
  List<Object?> get props => [serviceId, motorcycleId];
}
