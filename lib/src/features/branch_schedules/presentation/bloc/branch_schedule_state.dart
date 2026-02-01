import 'package:equatable/equatable.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/day_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_detail_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_exception_entity.dart';

/// Loading section indicators for granular loading states.
enum LoadingSection { none, details, exceptions }

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
  final List<ScheduleExceptionEntity> exceptions;
  final String? message;
  final bool isSuccess;

  /// Indicates which section is currently loading (for granular loading indicators).
  final LoadingSection loadingSection;

  const BranchScheduleLoaded({
    required this.schedule,
    this.daysCatalog = const [],
    this.details = const [],
    this.exceptions = const [],
    this.message,
    this.isSuccess = true,
    this.loadingSection = LoadingSection.none,
  });

  /// Returns true if details section is loading.
  bool get isDetailsLoading => loadingSection == LoadingSection.details;

  /// Returns true if exceptions section is loading.
  bool get isExceptionsLoading => loadingSection == LoadingSection.exceptions;

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

  /// Returns exceptions sorted by date (nearest first).
  List<ScheduleExceptionEntity> get sortedExceptions {
    final sorted = List<ScheduleExceptionEntity>.from(exceptions);
    sorted.sort((a, b) => a.exceptionStartDate.compareTo(b.exceptionStartDate));
    return sorted;
  }

  BranchScheduleLoaded copyWith({
    ScheduleEntity? schedule,
    List<DayEntity>? daysCatalog,
    List<ScheduleDetailEntity>? details,
    List<ScheduleExceptionEntity>? exceptions,
    String? message,
    bool? isSuccess,
    LoadingSection? loadingSection,
  }) {
    return BranchScheduleLoaded(
      schedule: schedule ?? this.schedule,
      daysCatalog: daysCatalog ?? this.daysCatalog,
      details: details ?? this.details,
      exceptions: exceptions ?? this.exceptions,
      message: message,
      isSuccess: isSuccess ?? this.isSuccess,
      loadingSection: loadingSection ?? LoadingSection.none,
    );
  }

  @override
  List<Object?> get props => [
    schedule,
    daysCatalog,
    details,
    exceptions,
    message,
    isSuccess,
    loadingSection,
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
