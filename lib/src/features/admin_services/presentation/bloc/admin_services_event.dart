import 'package:equatable/equatable.dart';

/// Events for AdminServicesBloc.
abstract class AdminServicesEvent extends Equatable {
  const AdminServicesEvent();

  @override
  List<Object?> get props => [];
}

/// Load all services from the catalog.
class LoadServices extends AdminServicesEvent {}

/// Refresh services (pull-to-refresh).
class RefreshServices extends AdminServicesEvent {}

/// Search/filter services.
class SearchServices extends AdminServicesEvent {
  final String query;
  final String? typeFilter;

  const SearchServices({required this.query, this.typeFilter});

  @override
  List<Object?> get props => [query, typeFilter];
}

/// Update a service (HU68).
class UpdateService extends AdminServicesEvent {
  final String serviceId;
  final String name;
  final String serviceType;
  final String? description;
  final bool? isActive;

  const UpdateService({
    required this.serviceId,
    required this.name,
    required this.serviceType,
    this.description,
    this.isActive,
  });

  @override
  List<Object?> get props => [
    serviceId,
    name,
    serviceType,
    description,
    isActive,
  ];
}

/// Toggle service active status (HU71, HU72).
class ToggleServiceStatus extends AdminServicesEvent {
  final String serviceId;
  final bool activate;

  const ToggleServiceStatus({required this.serviceId, required this.activate});

  @override
  List<Object?> get props => [serviceId, activate];
}
