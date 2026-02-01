import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/service_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/repositories/catalogs_repository.dart';
import 'package:motogo_frontend/src/core/constants/service_constants.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/branch_services/data/datasources/branch_services_datasource.dart';
import 'package:motogo_frontend/src/features/branch_services/domain/entities/branch_service_entity.dart';
import 'package:motogo_frontend/src/features/branch_services/presentation/bloc/branch_services_event.dart';
import 'package:motogo_frontend/src/features/branch_services/presentation/bloc/branch_services_state.dart';

/// BLoC for managing branch services.
///
/// Handles loading services from the catalog and branch,
/// filtering by type, searching, and toggling associations.
class BranchServicesBloc
    extends Bloc<BranchServicesEvent, BranchServicesState> {
  final CatalogsRepository _catalogsRepository;
  final BranchServicesDataSource _branchServicesDataSource;

  String? _currentBranchId;

  BranchServicesBloc({
    CatalogsRepository? catalogsRepository,
    BranchServicesDataSource? branchServicesDataSource,
  }) : _catalogsRepository =
           catalogsRepository ?? InjectorApp.resolve<CatalogsRepository>(),
       _branchServicesDataSource =
           branchServicesDataSource ??
           InjectorApp.resolve<BranchServicesDataSource>(),
       super(const BranchServicesInitial()) {
    on<LoadBranchServices>(_onLoadBranchServices);
    on<FilterServicesByType>(_onFilterByType);
    on<SearchServices>(_onSearch);
    on<ToggleServiceAssociation>(_onToggleAssociation);
  }

  Future<void> _onLoadBranchServices(
    LoadBranchServices event,
    Emitter<BranchServicesState> emit,
  ) async {
    _currentBranchId = event.branchId;
    emit(const BranchServicesLoading());

    // Load catalog services and branch services in parallel
    final catalogResult = await _catalogsRepository.getServices();
    final branchResult = await _branchServicesDataSource.getBranchServices(
      event.branchId,
    );

    if (catalogResult.isLeft) {
      emit(BranchServicesError(catalogResult.left.message));
      return;
    }

    final allServices = catalogResult.right;
    final branchServices = branchResult.isRight
        ? branchResult.right.map((m) => m.toEntity()).toList()
        : <BranchServiceEntity>[];

    emit(
      BranchServicesLoaded(
        allServices: allServices,
        branchServices: branchServices,
        displayedServices: allServices,
      ),
    );
  }

  void _onFilterByType(
    FilterServicesByType event,
    Emitter<BranchServicesState> emit,
  ) {
    final currentState = state;
    if (currentState is! BranchServicesLoaded) return;

    final filterType = event.serviceType == ServiceConstants.filterAll
        ? null
        : event.serviceType;

    final filtered = _filterServices(
      currentState.allServices,
      filterType,
      currentState.searchQuery,
    );

    emit(
      currentState.copyWith(
        filterType: filterType,
        displayedServices: filtered,
      ),
    );
  }

  void _onSearch(SearchServices event, Emitter<BranchServicesState> emit) {
    final currentState = state;
    if (currentState is! BranchServicesLoaded) return;

    final filtered = _filterServices(
      currentState.allServices,
      currentState.filterType,
      event.query,
    );

    emit(
      currentState.copyWith(
        searchQuery: event.query,
        displayedServices: filtered,
      ),
    );
  }

  Future<void> _onToggleAssociation(
    ToggleServiceAssociation event,
    Emitter<BranchServicesState> emit,
  ) async {
    if (_currentBranchId == null) return;
    final currentState = state;
    if (currentState is! BranchServicesLoaded) return;

    // Optimistic update: update UI immediately
    final updatedBranchServices = List<BranchServiceEntity>.from(
      currentState.branchServices,
    );

    if (event.associate) {
      // Add to associated services
      final service = currentState.allServices.firstWhere(
        (s) => s.id == event.serviceId,
      );
      updatedBranchServices.add(
        BranchServiceEntity(
          id: service.id,
          name: service.name,
          description: service.description,
          serviceType: service.serviceType,
          addedAt: DateTime.now(),
          active: true,
        ),
      );
    } else {
      // Remove from associated services
      updatedBranchServices.removeWhere((s) => s.id == event.serviceId);
    }

    // Emit optimistic state
    emit(currentState.copyWith(branchServices: updatedBranchServices));

    // Make API call
    final result = event.associate
        ? await _branchServicesDataSource.associateService(
            _currentBranchId!,
            event.serviceId,
          )
        : await _branchServicesDataSource.dissociateService(
            _currentBranchId!,
            event.serviceId,
          );

    // Handle result and emit message
    result.fold(
      (error) {
        // Revert to previous state and show error
        emit(currentState.copyWith(message: error.message, isSuccess: false));
      },
      (message) {
        // Keep new state and show success message
        emit(
          currentState.copyWith(
            branchServices: updatedBranchServices,
            message: message,
            isSuccess: true,
          ),
        );
      },
    );
  }

  List<ServiceEntity> _filterServices(
    List<ServiceEntity> services,
    String? type,
    String query,
  ) {
    var filtered = services;

    // Filter by type
    if (type != null && type.isNotEmpty) {
      filtered = filtered
          .where((s) => s.serviceType.toLowerCase() == type.toLowerCase())
          .toList();
    }

    // Filter by search query
    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      filtered = filtered
          .where(
            (s) =>
                s.name.toLowerCase().contains(lowerQuery) ||
                s.description.toLowerCase().contains(lowerQuery),
          )
          .toList();
    }

    return filtered;
  }
}
