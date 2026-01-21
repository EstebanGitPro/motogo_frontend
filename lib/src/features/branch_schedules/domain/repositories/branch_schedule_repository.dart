import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/day_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_entity.dart';

/// Repository contract for branch schedule operations.
abstract class BranchScheduleRepository {
  /// Gets the schedule for a specific branch.
  /// Returns null in the Right if no schedule exists.
  Future<Either<ErrorModel, ScheduleEntity?>> getSchedule(String branchId);

  /// Creates a schedule for a branch.
  Future<Either<ErrorModel, ScheduleEntity>> createSchedule(String branchId);

  /// Updates a schedule with new values.
  Future<Either<ErrorModel, ScheduleEntity>> updateSchedule(
    String branchId, {
    bool? active,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Deletes the schedule for a branch.
  Future<Either<ErrorModel, String>> deleteSchedule(String branchId);

  /// Activates the schedule for a branch.
  Future<Either<ErrorModel, ScheduleEntity>> activateSchedule(String branchId);

  /// Deactivates the schedule for a branch.
  Future<Either<ErrorModel, ScheduleEntity>> deactivateSchedule(
    String branchId,
  );

  /// Gets the days catalog.
  Future<Either<ErrorModel, List<DayEntity>>> getDaysCatalog();
}
