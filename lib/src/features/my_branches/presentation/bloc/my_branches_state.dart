import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';

/// States for the MyBranches BLoC.
abstract class MyBranchesState {}

/// Initial state before loading.
class MyBranchesInitial extends MyBranchesState {}

/// Loading state while fetching branches.
class MyBranchesLoading extends MyBranchesState {}

/// Loaded state with the list of branches.
class MyBranchesLoaded extends MyBranchesState {
  final List<BranchEntity> branches;
  final List<BranchEntity> filteredBranches;
  final String searchQuery;

  MyBranchesLoaded({
    required this.branches,
    required this.filteredBranches,
    this.searchQuery = '',
  });

  /// Creates a copy with optional overrides.
  MyBranchesLoaded copyWith({
    List<BranchEntity>? branches,
    List<BranchEntity>? filteredBranches,
    String? searchQuery,
  }) {
    return MyBranchesLoaded(
      branches: branches ?? this.branches,
      filteredBranches: filteredBranches ?? this.filteredBranches,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Error state when loading fails.
class MyBranchesError extends MyBranchesState {
  final ErrorModel error;

  MyBranchesError({required this.error});
}
