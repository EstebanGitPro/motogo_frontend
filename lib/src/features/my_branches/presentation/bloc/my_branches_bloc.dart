import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/features/my_branches/domain/usecases/get_branches_usecase.dart';
import 'package:motogo_frontend/src/features/my_branches/presentation/bloc/my_branches_event.dart';
import 'package:motogo_frontend/src/features/my_branches/presentation/bloc/my_branches_state.dart';

/// BLoC for managing the branches list state.
class MyBranchesBloc extends Bloc<MyBranchesEvent, MyBranchesState> {
  final GetBranchesUseCase getBranchesUseCase;

  MyBranchesBloc(this.getBranchesUseCase) : super(MyBranchesInitial()) {
    on<LoadBranches>(_onLoadBranches);
    on<RefreshBranches>(_onRefreshBranches);
    on<SearchBranches>(_onSearchBranches);
  }

  Future<void> _onLoadBranches(
    LoadBranches event,
    Emitter<MyBranchesState> emit,
  ) async {
    emit(MyBranchesLoading());
    await _fetchBranches(emit);
  }

  Future<void> _onRefreshBranches(
    RefreshBranches event,
    Emitter<MyBranchesState> emit,
  ) async {
    await _fetchBranches(emit);
  }

  Future<void> _fetchBranches(Emitter<MyBranchesState> emit) async {
    final result = await getBranchesUseCase.call();

    result.fold(
      (error) => emit(MyBranchesError(error: error)),
      (branches) => emit(
        MyBranchesLoaded(branches: branches, filteredBranches: branches),
      ),
    );
  }

  void _onSearchBranches(SearchBranches event, Emitter<MyBranchesState> emit) {
    final currentState = state;
    if (currentState is MyBranchesLoaded) {
      final query = event.query.toLowerCase().trim();

      if (query.isEmpty) {
        emit(
          currentState.copyWith(
            filteredBranches: currentState.branches,
            searchQuery: '',
          ),
        );
      } else {
        final filtered = currentState.branches.where((branch) {
          return branch.name.toLowerCase().contains(query) ||
              branch.address.toLowerCase().contains(query);
        }).toList();

        emit(
          currentState.copyWith(filteredBranches: filtered, searchQuery: query),
        );
      }
    }
  }
}
