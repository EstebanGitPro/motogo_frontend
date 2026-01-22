import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/branch_schedules/data/models/day_model.dart';
import 'package:motogo_frontend/src/features/branch_schedules/data/models/schedule_detail_model.dart';
import 'package:motogo_frontend/src/features/branch_schedules/data/models/schedule_model.dart';

/// DataSource contract for branch schedule operations.
///
/// Handles CRUD operations on branch schedules and schedule details.
/// Requires REPRESENTATIVE role for write operations.
abstract class BranchScheduleDataSource {
  /// Gets the schedule for a specific branch.
  /// Returns null in the Right if no schedule exists (404).
  Future<Either<ErrorModel, ScheduleModel?>> getSchedule(String branchId);

  /// Creates a schedule for a branch.
  Future<Either<ErrorModel, ScheduleModel>> createSchedule(String branchId);

  /// Updates a schedule with new values.
  /// [active] - Whether the schedule is active.
  /// [startDate] - Start date of validity (YYYY-MM-DD).
  /// [endDate] - End date of validity (null = indefinite).
  Future<Either<ErrorModel, ScheduleModel>> updateSchedule(
    String branchId, {
    bool? active,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Deletes the schedule for a branch.
  Future<Either<ErrorModel, String>> deleteSchedule(String branchId);

  /// Activates the schedule for a branch.
  Future<Either<ErrorModel, ScheduleModel>> activateSchedule(String branchId);

  /// Deactivates the schedule for a branch.
  Future<Either<ErrorModel, ScheduleModel>> deactivateSchedule(String branchId);

  /// Gets the days catalog.
  Future<Either<ErrorModel, List<DayModel>>> getDaysCatalog();

  // ========== Schedule Details ==========

  /// Gets all schedule details (time slots) for a branch.
  Future<Either<ErrorModel, List<ScheduleDetailModel>>> getScheduleDetails(
    String branchId,
  );

  /// Creates a new time slot for a day.
  Future<Either<ErrorModel, ScheduleDetailModel>> createScheduleDetail(
    String branchId, {
    required int dayOfWeek,
    required String openingTime,
    required String closingTime,
    required bool isClosed,
  });

  /// Updates an existing time slot.
  Future<Either<ErrorModel, ScheduleDetailModel>> updateScheduleDetail(
    String detailId, {
    required String openingTime,
    required String closingTime,
    required bool isClosed,
  });

  /// Deletes a time slot.
  Future<Either<ErrorModel, String>> deleteScheduleDetail(String detailId);
}
