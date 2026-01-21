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

  /// Map of franchise ID to franchise name for badge display.
  final Map<String, String> franchiseNames;

  /// Set of branch IDs that already belong to a franchise.
  /// Used to filter available branches when creating a new franchise.
  final Set<String> branchesWithFranchise;

  MyBranchesLoaded({
    required this.branches,
    required this.filteredBranches,
    this.searchQuery = '',
    this.franchiseNames = const {},
    this.branchesWithFranchise = const {},
  });

  /// Creates a copy with optional overrides.
  MyBranchesLoaded copyWith({
    List<BranchEntity>? branches,
    List<BranchEntity>? filteredBranches,
    String? searchQuery,
    Map<String, String>? franchiseNames,
    Set<String>? branchesWithFranchise,
  }) {
    return MyBranchesLoaded(
      branches: branches ?? this.branches,
      filteredBranches: filteredBranches ?? this.filteredBranches,
      searchQuery: searchQuery ?? this.searchQuery,
      franchiseNames: franchiseNames ?? this.franchiseNames,
      branchesWithFranchise:
          branchesWithFranchise ?? this.branchesWithFranchise,
    );
  }
}

/// Error state when loading fails.
class MyBranchesError extends MyBranchesState {
  final ErrorModel error;

  MyBranchesError({required this.error});
}
