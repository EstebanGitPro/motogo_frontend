import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/branch_schedules/data/models/day_model.dart';
import 'package:motogo_frontend/src/features/branch_schedules/data/models/schedule_detail_model.dart';
import 'package:motogo_frontend/src/features/branch_schedules/data/models/schedule_exception_model.dart';
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
  /// Returns a record containing the created schedule and success message.
  Future<Either<ErrorModel, (ScheduleModel, String)>> createSchedule(
    String branchId,
  );

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
  /// Returns a record containing the updated schedule and success message.
  Future<Either<ErrorModel, (ScheduleModel, String)>> activateSchedule(
    String branchId,
  );

  /// Deactivates the schedule for a branch.
  /// Returns a record containing the updated schedule and success message.
  Future<Either<ErrorModel, (ScheduleModel, String)>> deactivateSchedule(
    String branchId,
  );

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
  /// HU23: Consultar Información de la Excepción Horario
  Future<Either<ErrorModel, List<ScheduleExceptionModel>>>
  getScheduleExceptions(String branchId);

  /// Creates a new schedule exception.
  /// HU20: Registrar Información de la Excepción de Horario
  /// Returns a record containing the created model and the success message.
  Future<Either<ErrorModel, (ScheduleExceptionModel, String)>>
  createScheduleException(
    String branchId, {
    required String exceptionStartDate,
    String? exceptionEndDate,
    required String openingTime,
    required String closingTime,
    required bool isClosed,
  });

  /// Updates an existing schedule exception.
  /// HU21: Modificar Información de la Excepción Horario
  /// Note: Dates cannot be modified, only times and is_closed.
  /// Returns success message (backend doesn't return updated entity).
  Future<Either<ErrorModel, String>> updateScheduleException(
    String exceptionId, {
    required String openingTime,
    required String closingTime,
    required bool isClosed,
  });

  /// Deletes a schedule exception.
  /// HU22: Eliminar Información de la Excepción Horario
  Future<Either<ErrorModel, String>> deleteScheduleException(
    String exceptionId,
  );

  /// Activates a schedule exception.
  /// HU24: Activar la Excepción Horario
  /// Returns success message (backend doesn't return updated entity).
  Future<Either<ErrorModel, String>> activateScheduleException(
    String exceptionId,
  );

  /// Deactivates a schedule exception.
  /// HU25: Desactivar la Excepción Horario
  /// Returns success message (backend doesn't return updated entity).
  Future<Either<ErrorModel, String>> deactivateScheduleException(
    String exceptionId,
  );
}
