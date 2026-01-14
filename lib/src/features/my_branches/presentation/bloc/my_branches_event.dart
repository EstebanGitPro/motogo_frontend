/// Events for the MyBranches BLoC.
abstract class MyBranchesEvent {}

/// Event to load the user's branches.
class LoadBranches extends MyBranchesEvent {}

/// Event to search/filter branches locally.
class SearchBranches extends MyBranchesEvent {
  final String query;

  SearchBranches({required this.query});
}

/// Event to refresh the branches list.
class RefreshBranches extends MyBranchesEvent {}
