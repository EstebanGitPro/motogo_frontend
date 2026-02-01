import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/entities/motorcycle_detail_entity.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/usecases/search_motorcycle_by_plate_usecase.dart';

part 'search_motorcycle_event.dart';
part 'search_motorcycle_state.dart';

/// BLoC for searching motorcycles by license plate.
///
/// Handles the HU47 workflow: user enters plate, search is performed,
/// and results are displayed.
class SearchMotorcycleBloc
    extends Bloc<SearchMotorcycleEvent, SearchMotorcycleState> {
  final SearchMotorcycleByPlateUseCase _searchUseCase;

  SearchMotorcycleBloc({SearchMotorcycleByPlateUseCase? searchUseCase})
    : _searchUseCase =
          searchUseCase ??
          InjectorApp.resolve<SearchMotorcycleByPlateUseCase>(),
      super(const SearchMotorcycleInitial()) {
    on<SearchByPlate>(_onSearchByPlate);
    on<ClearSearch>(_onClearSearch);
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
}
