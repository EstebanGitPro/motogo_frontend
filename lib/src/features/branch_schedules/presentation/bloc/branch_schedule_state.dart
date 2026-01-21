import 'package:equatable/equatable.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/day_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_entity.dart';

/// States for BranchScheduleBloc.
abstract class BranchScheduleState extends Equatable {
  const BranchScheduleState();

  @override
  List<Object?> get props => [];
}

/// Initial state before loading.
class BranchScheduleInitial extends BranchScheduleState {}

/// Loading state while fetching schedule.
class BranchScheduleLoading extends BranchScheduleState {}

/// Schedule loaded successfully.
class BranchScheduleLoaded extends BranchScheduleState {
  final ScheduleEntity schedule;
  final List<DayEntity> daysCatalog;
  final String? message;
  final bool isSuccess;

  const BranchScheduleLoaded({
    required this.schedule,
    this.daysCatalog = const [],
    this.message,
    this.isSuccess = true,
  });

  BranchScheduleLoaded copyWith({
    ScheduleEntity? schedule,
    List<DayEntity>? daysCatalog,
    String? message,
    bool? isSuccess,
  }) {
    return BranchScheduleLoaded(
      schedule: schedule ?? this.schedule,
      daysCatalog: daysCatalog ?? this.daysCatalog,
      message: message,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [schedule, daysCatalog, message, isSuccess];
}

/// No schedule exists for this branch yet.
class BranchScheduleNotFound extends BranchScheduleState {
  final List<DayEntity> daysCatalog;
  final String? message;
  final bool isSuccess;

  const BranchScheduleNotFound({
    this.daysCatalog = const [],
    this.message,
    this.isSuccess = true,
  });

  @override
  List<Object?> get props => [daysCatalog, message, isSuccess];
}

/// Error state.
class BranchScheduleError extends BranchScheduleState {
  final String message;

  const BranchScheduleError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State during an operation (create, delete, toggle).
class BranchScheduleOperating extends BranchScheduleState {
  final String operation;

  const BranchScheduleOperating(this.operation);

  @override
  List<Object?> get props => [operation];
}
