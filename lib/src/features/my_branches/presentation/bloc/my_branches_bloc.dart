import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/manage_franchise/domain/usecases/franchise_usecases.dart';
import 'package:motogo_frontend/src/features/my_branches/domain/usecases/get_branches_usecase.dart';
import 'package:motogo_frontend/src/features/my_branches/presentation/bloc/my_branches_event.dart';
import 'package:motogo_frontend/src/features/my_branches/presentation/bloc/my_branches_state.dart';

/// BLoC for managing the branches list state.
class MyBranchesBloc extends Bloc<MyBranchesEvent, MyBranchesState> {
  final GetBranchesUseCase _getBranchesUseCase;
  final ListFranchisesUseCase? _listFranchisesUseCase;

  MyBranchesBloc({
    GetBranchesUseCase? getBranchesUseCase,
    ListFranchisesUseCase? listFranchisesUseCase,
  }) : _getBranchesUseCase =
           getBranchesUseCase ?? InjectorApp.resolve<GetBranchesUseCase>(),
       _listFranchisesUseCase = listFranchisesUseCase,
       super(MyBranchesInitial()) {
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
    final result = await _getBranchesUseCase.call();

    // Build franchise names map and collect all branch IDs that belong to franchises
    Map<String, String> franchiseNames = {};
    Set<String> branchesWithFranchise = {};

    if (_listFranchisesUseCase != null) {
      final franchisesResult = await _listFranchisesUseCase.call();
      franchisesResult.fold(
        (_) {}, // Ignore errors, just don't show badge
        (franchises) {
          for (final f in franchises) {
            if (f.id != null) {
              franchiseNames[f.id!] = f.name;
            }
            // Collect all branch IDs that belong to this franchise
            branchesWithFranchise.addAll(f.branchIds);
          }
        },
      );
    }

    result.fold((error) => emit(MyBranchesError(error: error)), (branches) {
      // Also add branches that have franchiseId set directly
      // This handles cases where the list endpoint doesn't include branch_ids
      for (final branch in branches) {
        if (branch.id != null && branch.franchiseId != null) {
          branchesWithFranchise.add(branch.id!);
        }
      }

      emit(
        MyBranchesLoaded(
          branches: branches,
          filteredBranches: branches,
          franchiseNames: franchiseNames,
          branchesWithFranchise: branchesWithFranchise,
        ),
      );
    });
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
