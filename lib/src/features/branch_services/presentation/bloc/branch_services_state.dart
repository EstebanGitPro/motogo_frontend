import 'package:equatable/equatable.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/service_entity.dart';
import 'package:motogo_frontend/src/features/branch_services/domain/entities/branch_service_entity.dart';

/// States for the BranchServicesBloc.
abstract class BranchServicesState extends Equatable {
  const BranchServicesState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any loading.
class BranchServicesInitial extends BranchServicesState {
  const BranchServicesInitial();
}

/// Loading state while fetching services.
class BranchServicesLoading extends BranchServicesState {
  const BranchServicesLoading();
}

/// Loaded state with all services and branch-associated services.
class BranchServicesLoaded extends BranchServicesState {
  /// All services from the catalog.
  final List<ServiceEntity> allServices;

  /// Services associated with the branch (with added_at info).
  final List<BranchServiceEntity> branchServices;

  /// Currently filtered services to display.
  final List<ServiceEntity> displayedServices;

  /// Current filter type (null = all).
  final String? filterType;

  /// Current search query.
  final String searchQuery;

  /// Message from backend operation (success or error).
  final String? message;

  /// Whether the last operation was successful.
  final bool? isSuccess;

  /// Set of service IDs that are associated with this branch.
  Set<String> get associatedServiceIds =>
      branchServices.map((s) => s.id).toSet();

  const BranchServicesLoaded({
    required this.allServices,
    required this.branchServices,
    required this.displayedServices,
    this.filterType,
    this.searchQuery = '',
    this.message,
    this.isSuccess,
  });

  /// Creates a copy with updated values.
  BranchServicesLoaded copyWith({
    List<ServiceEntity>? allServices,
    List<BranchServiceEntity>? branchServices,
    List<ServiceEntity>? displayedServices,
    String? filterType,
    String? searchQuery,
    String? message,
    bool? isSuccess,
  }) {
    return BranchServicesLoaded(
      allServices: allServices ?? this.allServices,
      branchServices: branchServices ?? this.branchServices,
      displayedServices: displayedServices ?? this.displayedServices,
      filterType: filterType ?? this.filterType,
      searchQuery: searchQuery ?? this.searchQuery,
      message: message,
      isSuccess: isSuccess,
    );
  }

  @override
  List<Object?> get props => [
    allServices,
    branchServices,
    displayedServices,
    filterType,
    searchQuery,
    message,
    isSuccess,
  ];
}

/// Error state when loading fails.
class BranchServicesError extends BranchServicesState {
  final String message;

  const BranchServicesError(this.message);

  @override
  List<Object?> get props => [message];
}
