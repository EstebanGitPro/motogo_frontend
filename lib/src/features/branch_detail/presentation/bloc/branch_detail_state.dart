part of 'branch_detail_bloc.dart';

/// Base state for branch detail.
abstract class BranchDetailState extends Equatable {
  const BranchDetailState();

  @override
  List<Object?> get props => [];
}

/// Initial state before loading.
class BranchDetailInitial extends BranchDetailState {
  const BranchDetailInitial();
}

/// Loading state while fetching data.
class BranchDetailLoading extends BranchDetailState {
  const BranchDetailLoading();
}

/// Loaded state with all branch data.
class BranchDetailLoaded extends BranchDetailState {
  final BranchDetailEntity detail;
  final List<BranchServiceEntity> services;
  final List<ScheduleDetailEntity> schedules;
  final bool isOpenNow;

  const BranchDetailLoaded({
    required this.detail,
    required this.services,
    required this.schedules,
    required this.isOpenNow,
  });

  @override
  List<Object?> get props => [detail, services, schedules, isOpenNow];
}

/// Error state when loading fails.
class BranchDetailError extends BranchDetailState {
  final String message;

  const BranchDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
