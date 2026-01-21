import 'package:equatable/equatable.dart';

/// Events for BranchScheduleBloc.
abstract class BranchScheduleEvent extends Equatable {
  const BranchScheduleEvent();

  @override
  List<Object?> get props => [];
}

/// Load schedule for a branch.
class LoadSchedule extends BranchScheduleEvent {
  final String branchId;

  const LoadSchedule(this.branchId);

  @override
  List<Object?> get props => [branchId];
}

/// Create schedule for a branch.
class CreateSchedule extends BranchScheduleEvent {
  final String branchId;

  const CreateSchedule(this.branchId);

  @override
  List<Object?> get props => [branchId];
}

/// Delete schedule for a branch.
class DeleteSchedule extends BranchScheduleEvent {
  final String branchId;

  const DeleteSchedule(this.branchId);

  @override
  List<Object?> get props => [branchId];
}

/// Toggle schedule status (activate/deactivate).
class ToggleScheduleStatus extends BranchScheduleEvent {
  final String branchId;
  final bool activate;

  const ToggleScheduleStatus({required this.branchId, required this.activate});

  @override
  List<Object?> get props => [branchId, activate];
}

/// Update schedule validity dates and status.
class UpdateSchedule extends BranchScheduleEvent {
  final String branchId;
  final bool? active;
  final DateTime? startDate;
  final DateTime? endDate;

  const UpdateSchedule({
    required this.branchId,
    this.active,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [branchId, active, startDate, endDate];
}

/// Clear any displayed message.
class ClearMessage extends BranchScheduleEvent {}
