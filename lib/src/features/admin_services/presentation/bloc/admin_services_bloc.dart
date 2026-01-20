import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/features/admin_services/domain/entities/admin_service_entity.dart';
import 'package:motogo_frontend/src/features/admin_services/domain/usecases/admin_service_usecases.dart';
import 'package:motogo_frontend/src/features/admin_services/presentation/bloc/admin_services_event.dart';
import 'package:motogo_frontend/src/features/admin_services/presentation/bloc/admin_services_state.dart';

/// BLoC for managing admin services catalog.
///
/// Handles:
/// - Loading and displaying the service catalog
/// - Searching and filtering services
/// - Updating service details (HU68)
/// - Activating/Deactivating services (HU71, HU72)
class AdminServicesBloc extends Bloc<AdminServicesEvent, AdminServicesState> {
  final GetServicesCatalogUseCase _getServicesUseCase;
  final UpdateServiceUseCase _updateServiceUseCase;
  final ActivateServiceUseCase _activateServiceUseCase;
  final DeactivateServiceUseCase _deactivateServiceUseCase;

  AdminServicesBloc({
    required GetServicesCatalogUseCase getServicesUseCase,
    required UpdateServiceUseCase updateServiceUseCase,
    required ActivateServiceUseCase activateServiceUseCase,
    required DeactivateServiceUseCase deactivateServiceUseCase,
  }) : _getServicesUseCase = getServicesUseCase,
       _updateServiceUseCase = updateServiceUseCase,
       _activateServiceUseCase = activateServiceUseCase,
       _deactivateServiceUseCase = deactivateServiceUseCase,
       super(AdminServicesInitial()) {
    on<LoadServices>(_onLoadServices);
    on<RefreshServices>(_onRefreshServices);
    on<SearchServices>(_onSearchServices);
    on<UpdateService>(_onUpdateService);
    on<ToggleServiceStatus>(_onToggleServiceStatus);
  }

  Future<void> _onLoadServices(
    LoadServices event,
    Emitter<AdminServicesState> emit,
  ) async {
    emit(AdminServicesLoading());
    await _loadServices(emit);
  }

  Future<void> _onRefreshServices(
    RefreshServices event,
    Emitter<AdminServicesState> emit,
  ) async {
    await _loadServices(emit);
  }

  Future<void> _loadServices(Emitter<AdminServicesState> emit) async {
    final result = await _getServicesUseCase();

    result.fold((error) => emit(AdminServicesError(error)), (services) {
      final types = _extractUniqueTypes(services);
      emit(
        AdminServicesLoaded(
          allServices: services,
          filteredServices: services,
          availableTypes: types,
        ),
      );
    });
  }

  void _onSearchServices(
    SearchServices event,
    Emitter<AdminServicesState> emit,
  ) {
    if (state is AdminServicesLoaded) {
      final currentState = state as AdminServicesLoaded;
      final filtered = _filterServices(
        currentState.allServices,
        event.query,
        event.typeFilter,
      );
      emit(
        currentState.copyWith(
          filteredServices: filtered,
          searchQuery: event.query,
          typeFilter: event.typeFilter,
        ),
      );
    }
  }

  Future<void> _onUpdateService(
    UpdateService event,
    Emitter<AdminServicesState> emit,
  ) async {
    if (state is AdminServicesLoaded) {
      final currentState = state as AdminServicesLoaded;

      emit(
        AdminServicesUpdating(
          allServices: currentState.allServices,
          filteredServices: currentState.filteredServices,
          updatingServiceId: event.serviceId,
        ),
      );

      final result = await _updateServiceUseCase(
        serviceId: event.serviceId,
        name: event.name,
        serviceType: event.serviceType,
        description: event.description,
        isActive: event.isActive,
      );

      result.fold(
        (error) {
          emit(AdminServicesError(error));
          // Restore previous state
          emit(currentState);
        },
        (updatedService) {
          // Update the service in the list
          final updatedList = currentState.allServices.map((service) {
            if (service.id == event.serviceId) {
              return updatedService;
            }
            return service;
          }).toList();

          final types = _extractUniqueTypes(updatedList);
          final filtered = _filterServices(
            updatedList,
            currentState.searchQuery,
            currentState.typeFilter,
          );

          emit(
            AdminServicesUpdateSuccess(
              message: 'Servicio actualizado exitosamente',
              previousState: AdminServicesLoaded(
                allServices: updatedList,
                filteredServices: filtered,
                searchQuery: currentState.searchQuery,
                typeFilter: currentState.typeFilter,
                availableTypes: types,
              ),
            ),
          );
        },
      );
    }
  }

  Future<void> _onToggleServiceStatus(
    ToggleServiceStatus event,
    Emitter<AdminServicesState> emit,
  ) async {
    if (state is AdminServicesLoaded) {
      final currentState = state as AdminServicesLoaded;

      emit(
        AdminServicesUpdating(
          allServices: currentState.allServices,
          filteredServices: currentState.filteredServices,
          updatingServiceId: event.serviceId,
        ),
      );

      final result = event.activate
          ? await _activateServiceUseCase(event.serviceId)
          : await _deactivateServiceUseCase(event.serviceId);

      result.fold(
        (error) {
          emit(AdminServicesError(error));
          // Restore previous state
          emit(currentState);
        },
        (message) {
          // Update the service status in the list
          final updatedList = currentState.allServices.map((service) {
            if (service.id == event.serviceId) {
              return service.copyWith(isActive: event.activate);
            }
            return service;
          }).toList();

          final filtered = _filterServices(
            updatedList,
            currentState.searchQuery,
            currentState.typeFilter,
          );

          emit(
            AdminServicesUpdateSuccess(
              message: message,
              previousState: AdminServicesLoaded(
                allServices: updatedList,
                filteredServices: filtered,
                searchQuery: currentState.searchQuery,
                typeFilter: currentState.typeFilter,
                availableTypes: currentState.availableTypes,
              ),
            ),
          );
        },
      );
    }
  }

  /// Extracts unique service types from the list.
  List<String> _extractUniqueTypes(List<AdminServiceEntity> services) {
    final types = services.map((s) => s.serviceType).toSet().toList();
    types.sort();
    return types;
  }

  /// Filters services based on query and type.
  List<AdminServiceEntity> _filterServices(
    List<AdminServiceEntity> services,
    String query,
    String? typeFilter,
  ) {
    var filtered = services;

    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      filtered = filtered.where((service) {
        return service.name.toLowerCase().contains(lowerQuery) ||
            (service.description?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    }

    if (typeFilter != null && typeFilter.isNotEmpty) {
      filtered = filtered.where((service) {
        return service.serviceType == typeFilter;
      }).toList();
    }

    return filtered;
  }
}
