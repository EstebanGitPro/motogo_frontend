import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/features/completed_services/data/model/register_completed_service_model.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/entities/completed_service_entity.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/entities/status_transition_entity.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/usecases/get_service_history_usecase.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/usecases/get_service_transitions_usecase.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/usecases/register_completed_service_usecase.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/usecases/update_service_status_usecase.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/usecases/update_service_details_usecase.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/usecases/delete_completed_service_usecase.dart';
import 'package:motogo_frontend/src/features/diagnostic/domain/entity/diagnostic_entity.dart';
import 'package:motogo_frontend/src/features/my_branches/domain/usecases/get_branches_usecase.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/entities/motorcycle_detail_entity.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/usecases/search_motorcycle_by_plate_usecase.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/usecases/set_solution_usecase.dart';

part 'search_motorcycle_event.dart';
part 'search_motorcycle_state.dart';

/// BLoC for searching motorcycles by license plate.
///
/// Handles the HU47 workflow: user enters plate, search is performed,
/// and results are displayed. Also allows workshop representatives
/// to set diagnostic solutions and register completed services.
class SearchMotorcycleBloc
    extends Bloc<SearchMotorcycleEvent, SearchMotorcycleState> {
  final SearchMotorcycleByPlateUseCase _searchUseCase;
  final SetSolutionUseCase _setSolutionUseCase;
  final RegisterCompletedServiceUseCase _registerServiceUseCase;
  final GetServiceHistoryUseCase _getServiceHistoryUseCase;
  final GetBranchesUseCase _getBranchesUseCase;
  final UpdateServiceStatusUseCase _updateServiceStatusUseCase;
  final GetServiceTransitionsUseCase _getServiceTransitionsUseCase;
  final DeleteCompletedServiceUseCase _deleteCompletedServiceUseCase;
  final UpdateServiceDetailsUseCase _updateServiceDetailsUseCase;

  /// Maps branchId → branchName for enriching history entities.
  Map<String, String> _branchNameMap = {};

  SearchMotorcycleBloc({
    required SearchMotorcycleByPlateUseCase searchUseCase,
    required SetSolutionUseCase setSolutionUseCase,
    required RegisterCompletedServiceUseCase registerServiceUseCase,
    required GetServiceHistoryUseCase getServiceHistoryUseCase,
    required GetBranchesUseCase getBranchesUseCase,
    required UpdateServiceStatusUseCase updateServiceStatusUseCase,
    required GetServiceTransitionsUseCase getServiceTransitionsUseCase,
    required DeleteCompletedServiceUseCase deleteCompletedServiceUseCase,
    required UpdateServiceDetailsUseCase updateServiceDetailsUseCase,
  }) : _searchUseCase = searchUseCase,
       _setSolutionUseCase = setSolutionUseCase,
       _registerServiceUseCase = registerServiceUseCase,
       _getServiceHistoryUseCase = getServiceHistoryUseCase,
       _getBranchesUseCase = getBranchesUseCase,
       _updateServiceStatusUseCase = updateServiceStatusUseCase,
       _getServiceTransitionsUseCase = getServiceTransitionsUseCase,
       _deleteCompletedServiceUseCase = deleteCompletedServiceUseCase,
       _updateServiceDetailsUseCase = updateServiceDetailsUseCase,
       super(const SearchMotorcycleInitial()) {
    on<SearchByPlate>(_onSearchByPlate);
    on<ClearSearch>(_onClearSearch);
    on<SetDiagnosticSolution>(_onSetSolution);
    on<RegisterCompletedService>(_onRegisterCompletedService);
    on<FetchServiceHistory>(_onFetchServiceHistory);
    on<UpdateServiceStatus>(_onUpdateServiceStatus);
    on<UpdateServiceDetails>(_onUpdateServiceDetails);
    on<FetchServiceTransitions>(_onFetchServiceTransitions);
    on<DeleteCompletedService>(_onDeleteCompletedService);
  }

  Future<void> _onSearchByPlate(
    SearchByPlate event,
    Emitter<SearchMotorcycleState> emit,
  ) async {
    emit(const SearchMotorcycleLoading());

    final result = await _searchUseCase(event.plate.toUpperCase().trim());

    result.fold((error) => emit(SearchMotorcycleError(error.message)), (
      motorcycle,
    ) {
      emit(SearchMotorcycleLoaded(motorcycle));
      // Auto-fetch service history using the representative's own branches
      _fetchHistoryForMotorcycle(motorcycle.id);
    });
  }

  void _onClearSearch(ClearSearch event, Emitter<SearchMotorcycleState> emit) {
    emit(const SearchMotorcycleInitial());
  }

  Future<void> _onSetSolution(
    SetDiagnosticSolution event,
    Emitter<SearchMotorcycleState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SearchMotorcycleLoaded) return;

    final result = await _setSolutionUseCase(
      diagnosticId: event.diagnosticId,
      solution: event.solution,
    );

    result.fold(
      (error) => emit(currentState.copyWith(solutionError: error.message)),
      (message) {
        // Update the diagnostic's possibleSolution in the local entity
        final updatedDiagnostics = currentState.motorcycle.diagnostics.map((d) {
          if (d.id == event.diagnosticId) {
            return DiagnosticEntity(
              id: d.id,
              motorcycleId: d.motorcycleId,
              branchId: d.branchId,
              problemDescription: d.problemDescription,
              possibleSolution: event.solution,
              date: d.date,
              evidence: d.evidence,
            );
          }
          return d;
        }).toList();

        final updatedMotorcycle = MotorcycleDetailEntity(
          id: currentState.motorcycle.id,
          licensePlate: currentState.motorcycle.licensePlate,
          year: currentState.motorcycle.year,
          currentMileage: currentState.motorcycle.currentMileage,
          profileImageUrl: currentState.motorcycle.profileImageUrl,
          reference: currentState.motorcycle.reference,
          diagnostics: updatedDiagnostics,
          evidence: currentState.motorcycle.evidence,
          permittedBranches: currentState.motorcycle.permittedBranches,
        );

        emit(
          currentState.copyWith(
            motorcycle: updatedMotorcycle,
            solutionMessage: message,
          ),
        );
      },
    );
  }

  Future<void> _onRegisterCompletedService(
    RegisterCompletedService event,
    Emitter<SearchMotorcycleState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SearchMotorcycleLoaded) return;

    emit(
      currentState.copyWith(
        registration: currentState.registration.copyWith(isRegistering: true),
      ),
    );

    final request = RegisterCompletedServiceModel(
      branchId: event.branchId,
      motorcycleId: event.motorcycleId,
      serviceIds: event.serviceIds,
      quotedPrice: event.quotedPrice,
      finalPrice: event.finalPrice,
      representativeNotes: event.representativeNotes,
    );

    final result = await _registerServiceUseCase(request);

    result.fold(
      (error) => emit(
        currentState.copyWith(
          registration: currentState.registration.copyWith(
            isRegistering: false,
            error: error.message,
          ),
        ),
      ),
      (message) {
        emit(
          currentState.copyWith(
            registration: currentState.registration.copyWith(
              isRegistering: false,
              message: message,
            ),
          ),
        );
        // Refresh service history with the newly registered service
        _fetchHistoryForMotorcycle(event.motorcycleId);
      },
    );
  }

  Future<void> _onFetchServiceHistory(
    FetchServiceHistory event,
    Emitter<SearchMotorcycleState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SearchMotorcycleLoaded) return;

    emit(
      currentState.copyWith(
        history: currentState.history.copyWith(loading: true),
      ),
    );

    final result = await _getServiceHistoryUseCase(
      motorcycleId: event.motorcycleId,
      branchIds: event.branchIds,
    );

    result.fold(
      (error) => emit(
        currentState.copyWith(
          history: currentState.history.copyWith(
            loading: false,
            error: error.message,
          ),
        ),
      ),
      (historyList) {
        // Enrich entities with branch name
        final enriched = historyList.map((e) {
          final name = _branchNameMap[e.branchId];
          return name != null
              ? CompletedServiceEntity(
                  id: e.id,
                  branchId: e.branchId,
                  motorcycleId: e.motorcycleId,
                  diagnosticId: e.diagnosticId,
                  status: e.status,
                  requestDate: e.requestDate,
                  quotedPrice: e.quotedPrice,
                  finalPrice: e.finalPrice,
                  representativeNotes: e.representativeNotes,
                  services: e.services,
                  branchName: name,
                )
              : e;
        }).toList();
        emit(
          currentState.copyWith(
            history: currentState.history.copyWith(
              loading: false,
              services: enriched,
            ),
          ),
        );
      },
    );
  }

  /// Fetches the representative's branches and dispatches FetchServiceHistory.
  Future<void> _fetchHistoryForMotorcycle(String motorcycleId) async {
    final branchResult = await _getBranchesUseCase();
    branchResult.fold(
      (_) {
        // Silently skip — can't fetch branches
      },
      (branches) {
        if (branches.isNotEmpty) {
          // Build branch name map for enrichment
          _branchNameMap = {
            for (final b in branches)
              if (b.id != null) b.id!: b.name,
          };
          add(
            FetchServiceHistory(
              motorcycleId: motorcycleId,
              branchIds: branches
                  .map((b) => b.id)
                  .where((id) => id != null)
                  .cast<String>()
                  .toList(),
            ),
          );
        }
      },
    );
  }

  Future<void> _onUpdateServiceStatus(
    UpdateServiceStatus event,
    Emitter<SearchMotorcycleState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SearchMotorcycleLoaded) return;

    emit(
      currentState.copyWith(
        action: currentState.action.copyWith(
          statusUpdate: currentState.action.statusUpdate.copyWith(
            isLoading: true,
          ),
        ),
      ),
    );

    final result = await _updateServiceStatusUseCase(
      event.serviceId,
      event.newStatus,
      finalPrice: event.finalPrice,
    );

    result.fold(
      (error) => emit(
        currentState.copyWith(
          action: currentState.action.copyWith(
            statusUpdate: const AsyncActionState().copyWith(
              error: error.message,
            ),
          ),
        ),
      ),
      (message) {
        emit(
          currentState.copyWith(
            action: currentState.action.copyWith(
              statusUpdate: const AsyncActionState().copyWith(message: message),
            ),
          ),
        );
        // Refresh service history to reflect the status change
        _fetchHistoryForMotorcycle(event.motorcycleId);
      },
    );
  }

  Future<void> _onUpdateServiceDetails(
    UpdateServiceDetails event,
    Emitter<SearchMotorcycleState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SearchMotorcycleLoaded) return;

    emit(
      currentState.copyWith(
        action: currentState.action.copyWith(
          detailsUpdate: currentState.action.detailsUpdate.copyWith(
            isLoading: true,
          ),
        ),
      ),
    );

    final result = await _updateServiceDetailsUseCase(
      event.serviceId,
      quotedPrice: event.quotedPrice,
      finalPrice: event.finalPrice,
      representativeNotes: event.representativeNotes,
    );

    result.fold(
      (error) => emit(
        currentState.copyWith(
          action: currentState.action.copyWith(
            detailsUpdate: const AsyncActionState().copyWith(
              error: error.message,
            ),
          ),
        ),
      ),
      (message) {
        emit(
          currentState.copyWith(
            action: currentState.action.copyWith(
              detailsUpdate: const AsyncActionState().copyWith(
                message: message,
              ),
            ),
          ),
        );
        // Refresh service history to reflect the updated details
        _fetchHistoryForMotorcycle(event.motorcycleId);
      },
    );
  }

  Future<void> _onFetchServiceTransitions(
    FetchServiceTransitions event,
    Emitter<SearchMotorcycleState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SearchMotorcycleLoaded) return;

    final result = await _getServiceTransitionsUseCase(event.serviceId);

    result.fold(
      (error) {
        // Silently skip — transitions are supplementary
      },
      (transitions) {
        final entities = transitions.map((t) => t.toEntity()).toList();
        emit(
          currentState.copyWith(
            history: currentState.history.copyWith(transitions: entities),
          ),
        );
      },
    );
  }

  Future<void> _onDeleteCompletedService(
    DeleteCompletedService event,
    Emitter<SearchMotorcycleState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SearchMotorcycleLoaded) return;

    emit(
      currentState.copyWith(
        action: currentState.action.copyWith(
          deleteAction: currentState.action.deleteAction.copyWith(
            isLoading: true,
          ),
        ),
      ),
    );

    final result = await _deleteCompletedServiceUseCase(event.serviceId);

    result.fold(
      (error) => emit(
        currentState.copyWith(
          action: currentState.action.copyWith(
            deleteAction: const AsyncActionState().copyWith(
              error: error.message,
            ),
          ),
        ),
      ),
      (message) {
        emit(
          currentState.copyWith(
            action: currentState.action.copyWith(
              deleteAction: const AsyncActionState().copyWith(message: message),
            ),
          ),
        );
        // Refresh service history to reflect the deletion
        _fetchHistoryForMotorcycle(event.motorcycleId);
      },
    );
  }
}
