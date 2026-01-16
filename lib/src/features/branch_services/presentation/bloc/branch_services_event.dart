import 'package:equatable/equatable.dart';

/// Events for the BranchServicesBloc.
abstract class BranchServicesEvent extends Equatable {
  const BranchServicesEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load services for a branch.
class LoadBranchServices extends BranchServicesEvent {
  final String branchId;

  const LoadBranchServices(this.branchId);

  @override
  List<Object?> get props => [branchId];
}

/// Event to filter services by type.
class FilterServicesByType extends BranchServicesEvent {
  final String? serviceType;

  const FilterServicesByType(this.serviceType);

  @override
  List<Object?> get props => [serviceType];
}

/// Event to search services by name.
class SearchServices extends BranchServicesEvent {
  final String query;

  const SearchServices(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event to toggle service association.
class ToggleServiceAssociation extends BranchServicesEvent {
  final String serviceId;
  final bool associate;

  const ToggleServiceAssociation({
    required this.serviceId,
    required this.associate,
  });

  @override
  List<Object?> get props => [serviceId, associate];
}
