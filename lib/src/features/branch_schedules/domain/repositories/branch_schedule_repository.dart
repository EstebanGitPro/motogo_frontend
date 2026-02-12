import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/day_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_detail_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_exception_entity.dart';

/// Repository contract for branch schedule operations.
abstract class BranchScheduleRepository {
  /// Gets the schedule for a specific branch.
  /// Returns null in the Right if no schedule exists.
  Future<Either<ErrorModel, ScheduleEntity?>> getSchedule(String branchId);

  /// Creates a schedule for a branch.
  /// Returns a record containing the created schedule and success message.
  Future<Either<ErrorModel, (ScheduleEntity, String)>> createSchedule(
    String branchId,
  );

  /// Updates a schedule with new values.
  Future<Either<ErrorModel, (ScheduleEntity, String)>> updateSchedule(
    String branchId, {
    bool? active,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Deletes the schedule for a branch.
  Future<Either<ErrorModel, String>> deleteSchedule(String branchId);

  /// Activates the schedule for a branch.
  /// Returns a record containing the updated schedule and success message.
  Future<Either<ErrorModel, (ScheduleEntity, String)>> activateSchedule(
    String branchId,
  );

  /// Deactivates the schedule for a branch.
  /// Returns a record containing the updated schedule and success message.
  Future<Either<ErrorModel, (ScheduleEntity, String)>> deactivateSchedule(
    String branchId,
  );

  /// Gets the days catalog.
  Future<Either<ErrorModel, List<DayEntity>>> getDaysCatalog();

  // ========== Schedule Details ==========

  /// Gets all schedule details (time slots) for a branch.
  Future<Either<ErrorModel, List<ScheduleDetailEntity>>> getScheduleDetails(
    String branchId,
  );

  /// Creates a new time slot for a day.
  Future<Either<ErrorModel, (ScheduleDetailEntity, String)>>
  createScheduleDetail(
    String branchId, {
    required int dayOfWeek,
    required String openingTime,
    required String closingTime,
    required bool isClosed,
  });

  /// Updates an existing time slot.
  /// Note: Day cannot be modified per API spec.
  /// Returns success message (backend doesn't return updated entity).
  Future<Either<ErrorModel, String>> updateScheduleDetail(
    String detailId, {
    required String openingTime,
    required String closingTime,
    required bool isClosed,
  });

  /// Deletes a time slot.
  Future<Either<ErrorModel, String>> deleteScheduleDetail(String detailId);

  // ========== Schedule Exceptions (HU20-25) ==========

  /// Gets all schedule exceptions for a branch.
  Future<Either<ErrorModel, List<ScheduleExceptionEntity>>>
  getScheduleExceptions(String branchId);

  /// Creates a new schedule exception.
  /// Returns a record containing the created entity and the success message.
  Future<Either<ErrorModel, (ScheduleExceptionEntity, String)>>
  createScheduleException(
    String branchId, {
    required String exceptionStartDate,
    String? exceptionEndDate,
    required String openingTime,
    required String closingTime,
    required bool isClosed,
  });

  /// Updates an existing schedule exception.
  /// Note: Dates cannot be modified, only times and is_closed.
  /// Returns success message (backend doesn't return updated entity).
  Future<Either<ErrorModel, String>> updateScheduleException(
    String exceptionId, {
    required String openingTime,
    required String closingTime,
    required bool isClosed,
  });

  /// Deletes a schedule exception.
  Future<Either<ErrorModel, String>> deleteScheduleException(
    String exceptionId,
  );

  /// Activates a schedule exception.
  /// Returns success message (backend doesn't return updated entity).
  Future<Either<ErrorModel, String>> activateScheduleException(
    String exceptionId,
  );

  /// Deactivates a schedule exception.
  /// Returns success message (backend doesn't return updated entity).
  Future<Either<ErrorModel, String>> deactivateScheduleException(
    String exceptionId,
  );
}
