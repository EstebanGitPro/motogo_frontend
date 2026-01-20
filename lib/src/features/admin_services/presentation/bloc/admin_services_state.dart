import 'package:equatable/equatable.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/admin_services/domain/entities/admin_service_entity.dart';

/// States for AdminServicesBloc.
abstract class AdminServicesState extends Equatable {
  const AdminServicesState();

  @override
  List<Object?> get props => [];
}

/// Initial state before loading.
class AdminServicesInitial extends AdminServicesState {}

/// Loading state while fetching services.
class AdminServicesLoading extends AdminServicesState {}

/// Services loaded successfully.
class AdminServicesLoaded extends AdminServicesState {
  /// All services from the catalog.
  final List<AdminServiceEntity> allServices;

  /// Filtered services based on search/filter.
  final List<AdminServiceEntity> filteredServices;

  /// Current search query.
  final String searchQuery;

  /// Current type filter.
  final String? typeFilter;

  /// Available service types for filtering.
  final List<String> availableTypes;

  const AdminServicesLoaded({
    required this.allServices,
    required this.filteredServices,
    this.searchQuery = '',
    this.typeFilter,
    this.availableTypes = const [],
  });

  AdminServicesLoaded copyWith({
    List<AdminServiceEntity>? allServices,
    List<AdminServiceEntity>? filteredServices,
    String? searchQuery,
    String? typeFilter,
    List<String>? availableTypes,
  }) {
    return AdminServicesLoaded(
      allServices: allServices ?? this.allServices,
      filteredServices: filteredServices ?? this.filteredServices,
      searchQuery: searchQuery ?? this.searchQuery,
      typeFilter: typeFilter,
      availableTypes: availableTypes ?? this.availableTypes,
    );
  }

  @override
  List<Object?> get props => [
    allServices,
    filteredServices,
    searchQuery,
    typeFilter,
    availableTypes,
  ];
}

/// Error state.
class AdminServicesError extends AdminServicesState {
  final ErrorModel error;

  const AdminServicesError(this.error);

  @override
  List<Object?> get props => [error];
}

/// State during service update/toggle operation.
class AdminServicesUpdating extends AdminServicesState {
  final List<AdminServiceEntity> allServices;
  final List<AdminServiceEntity> filteredServices;
  final String updatingServiceId;

  const AdminServicesUpdating({
    required this.allServices,
    required this.filteredServices,
    required this.updatingServiceId,
  });

  @override
  List<Object?> get props => [allServices, filteredServices, updatingServiceId];
}

/// State after successful update.
class AdminServicesUpdateSuccess extends AdminServicesState {
  final String message;
  final AdminServicesLoaded previousState;

  const AdminServicesUpdateSuccess({
    required this.message,
    required this.previousState,
  });

  @override
  List<Object?> get props => [message, previousState];
}
