part of 'branch_detail_bloc.dart';

/// Base event for branch detail.
abstract class BranchDetailEvent extends Equatable {
  const BranchDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load the branch detail.
class LoadBranchDetail extends BranchDetailEvent {
  final String branchId;

  const LoadBranchDetail(this.branchId);

  @override
  List<Object?> get props => [branchId];
}
