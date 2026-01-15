import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/features/manage_franchise/domain/usecases/franchise_usecases.dart';
import 'package:motogo_frontend/src/features/my_branches/domain/usecases/get_branches_usecase.dart';
import 'package:motogo_frontend/src/features/my_branches/presentation/bloc/my_branches_event.dart';
import 'package:motogo_frontend/src/features/my_branches/presentation/bloc/my_branches_state.dart';

/// BLoC for managing the branches list state.
class MyBranchesBloc extends Bloc<MyBranchesEvent, MyBranchesState> {
  final GetBranchesUseCase getBranchesUseCase;
  final ListFranchisesUseCase? listFranchisesUseCase;

  MyBranchesBloc(this.getBranchesUseCase, {this.listFranchisesUseCase})
    : super(MyBranchesInitial()) {
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

    // Build franchise names map
    Map<String, String> franchiseNames = {};
    if (listFranchisesUseCase != null) {
      final franchisesResult = await listFranchisesUseCase!.call();
      franchisesResult.fold(
        (_) {}, // Ignore errors, just don't show badge
        (franchises) {
          for (final f in franchises) {
            if (f.id != null) {
              franchiseNames[f.id!] = f.name;
            }
          }
        },
      );
    }

    result.fold(
      (error) => emit(MyBranchesError(error: error)),
      (branches) => emit(
        MyBranchesLoaded(
          branches: branches,
          filteredBranches: branches,
          franchiseNames: franchiseNames,
        ),
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
