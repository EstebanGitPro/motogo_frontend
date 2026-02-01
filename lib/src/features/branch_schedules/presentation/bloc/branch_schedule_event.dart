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

// ========== Schedule Details Events ==========

/// Load schedule details (time slots) for a branch.
class LoadScheduleDetails extends BranchScheduleEvent {
  final String branchId;

  const LoadScheduleDetails(this.branchId);

  @override
  List<Object?> get props => [branchId];
}

/// Create a new time slot.
class CreateScheduleDetail extends BranchScheduleEvent {
  final String branchId;
  final int dayOfWeek;
  final String openingTime;
  final String closingTime;
  final bool isClosed;

  const CreateScheduleDetail({
    required this.branchId,
    required this.dayOfWeek,
    required this.openingTime,
    required this.closingTime,
    this.isClosed = false,
  });

  @override
  List<Object?> get props => [
    branchId,
    dayOfWeek,
    openingTime,
    closingTime,
    isClosed,
  ];
}

/// Update an existing time slot.
class UpdateScheduleDetail extends BranchScheduleEvent {
  final String branchId;
  final String detailId;
  final String openingTime;
  final String closingTime;
  final bool isClosed;

  const UpdateScheduleDetail({
    required this.branchId,
    required this.detailId,
    required this.openingTime,
    required this.closingTime,
    this.isClosed = false,
  });

  @override
  List<Object?> get props => [
    branchId,
    detailId,
    openingTime,
    closingTime,
    isClosed,
  ];
}

/// Delete a time slot.
class DeleteScheduleDetail extends BranchScheduleEvent {
  final String branchId;
  final String detailId;

  const DeleteScheduleDetail({required this.branchId, required this.detailId});

  @override
  List<Object?> get props => [branchId, detailId];
}

// ========== Schedule Exception Events (HU20-25) ==========

/// Load schedule exceptions for a branch.
class LoadScheduleExceptions extends BranchScheduleEvent {
  final String branchId;

  const LoadScheduleExceptions(this.branchId);

  @override
  List<Object?> get props => [branchId];
}

/// Create a new schedule exception.
class CreateScheduleException extends BranchScheduleEvent {
  final String branchId;
  final String exceptionStartDate;
  final String? exceptionEndDate;
  final String openingTime;
  final String closingTime;
  final bool isClosed;

  const CreateScheduleException({
    required this.branchId,
    required this.exceptionStartDate,
    this.exceptionEndDate,
    required this.openingTime,
    required this.closingTime,
    this.isClosed = false,
  });

  @override
  List<Object?> get props => [
    branchId,
    exceptionStartDate,
    exceptionEndDate,
    openingTime,
    closingTime,
    isClosed,
  ];
}

/// Update an existing schedule exception.
/// Note: Dates cannot be modified, only times and is_closed.
class UpdateScheduleException extends BranchScheduleEvent {
  final String branchId;
  final String exceptionId;
  final String openingTime;
  final String closingTime;
  final bool isClosed;

  const UpdateScheduleException({
    required this.branchId,
    required this.exceptionId,
    required this.openingTime,
    required this.closingTime,
    this.isClosed = false,
  });

  @override
  List<Object?> get props => [
    branchId,
    exceptionId,
    openingTime,
    closingTime,
    isClosed,
  ];
}

/// Delete a schedule exception.
class DeleteScheduleException extends BranchScheduleEvent {
  final String branchId;
  final String exceptionId;

  const DeleteScheduleException({
    required this.branchId,
    required this.exceptionId,
  });

  @override
  List<Object?> get props => [branchId, exceptionId];
}

/// Toggle schedule exception status (activate/deactivate).
class ToggleScheduleExceptionStatus extends BranchScheduleEvent {
  final String branchId;
  final String exceptionId;
  final bool activate;

  const ToggleScheduleExceptionStatus({
    required this.branchId,
    required this.exceptionId,
    required this.activate,
  });

  @override
  List<Object?> get props => [branchId, exceptionId, activate];
}
