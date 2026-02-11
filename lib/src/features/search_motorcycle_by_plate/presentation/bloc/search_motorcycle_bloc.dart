import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/features/diagnostic/domain/entity/diagnostic_entity.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/entities/motorcycle_detail_entity.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/usecases/search_motorcycle_by_plate_usecase.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/usecases/set_solution_usecase.dart';

part 'search_motorcycle_event.dart';
part 'search_motorcycle_state.dart';

/// BLoC for searching motorcycles by license plate.
///
/// Handles the HU47 workflow: user enters plate, search is performed,
/// and results are displayed. Also allows workshop representatives
/// to set diagnostic solutions.
class SearchMotorcycleBloc
    extends Bloc<SearchMotorcycleEvent, SearchMotorcycleState> {
  final SearchMotorcycleByPlateUseCase _searchUseCase;
  final SetSolutionUseCase _setSolutionUseCase;

  SearchMotorcycleBloc({
    required SearchMotorcycleByPlateUseCase searchUseCase,
    required SetSolutionUseCase setSolutionUseCase,
  }) : _searchUseCase = searchUseCase,
       _setSolutionUseCase = setSolutionUseCase,
       super(const SearchMotorcycleInitial()) {
    on<SearchByPlate>(_onSearchByPlate);
    on<ClearSearch>(_onClearSearch);
    on<SetDiagnosticSolution>(_onSetSolution);
  }

  Future<void> _onSearchByPlate(
    SearchByPlate event,
    Emitter<SearchMotorcycleState> emit,
  ) async {
    emit(const SearchMotorcycleLoading());

    final result = await _searchUseCase(event.plate.toUpperCase().trim());

    result.fold(
      (error) => emit(SearchMotorcycleError(error.message)),
      (motorcycle) => emit(SearchMotorcycleLoaded(motorcycle)),
    );
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
              sentViaWhatsapp: d.sentViaWhatsapp,
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
}
