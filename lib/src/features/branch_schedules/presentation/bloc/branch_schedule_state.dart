import 'package:equatable/equatable.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/day_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_detail_entity.dart';
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
  final List<ScheduleDetailEntity> details;
  final String? message;
  final bool isSuccess;

  const BranchScheduleLoaded({
    required this.schedule,
    this.daysCatalog = const [],
    this.details = const [],
    this.message,
    this.isSuccess = true,
  });

  /// Groups details by day of week for easy access.
  /// Returns a map where key is dayOfWeek (1-7) and value is list of details.
  Map<int, List<ScheduleDetailEntity>> get detailsByDay {
    final map = <int, List<ScheduleDetailEntity>>{};
    for (final detail in details) {
      map.putIfAbsent(detail.dayOfWeek, () => []).add(detail);
    }
    // Sort each day's details by opening time
    for (final list in map.values) {
      list.sort((a, b) => a.openingTime.compareTo(b.openingTime));
    }
    return map;
  }

  BranchScheduleLoaded copyWith({
    ScheduleEntity? schedule,
    List<DayEntity>? daysCatalog,
    List<ScheduleDetailEntity>? details,
    String? message,
    bool? isSuccess,
  }) {
    return BranchScheduleLoaded(
      schedule: schedule ?? this.schedule,
      daysCatalog: daysCatalog ?? this.daysCatalog,
      details: details ?? this.details,
      message: message,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [
    schedule,
    daysCatalog,
    details,
    message,
    isSuccess,
  ];
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
