import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/branch_schedules/data/datasources/branch_schedule_datasource.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/day_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_detail_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_exception_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/repositories/branch_schedule_repository.dart';

/// Implementation of [BranchScheduleRepository].
class BranchScheduleRepositoryImpl implements BranchScheduleRepository {
  final BranchScheduleDataSource _dataSource;

  BranchScheduleRepositoryImpl(this._dataSource);

  @override
  Future<Either<ErrorModel, ScheduleEntity?>> getSchedule(
    String branchId,
  ) async {
    return _dataSource.getSchedule(branchId);
  }

  @override
  Future<Either<ErrorModel, (ScheduleEntity, String)>> createSchedule(
    String branchId,
  ) async {
    final result = await _dataSource.createSchedule(branchId);
    return result.map((record) => (record.$1, record.$2));
  }

  @override
  Future<Either<ErrorModel, ScheduleEntity>> updateSchedule(
    String branchId, {
    bool? active,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _dataSource.updateSchedule(
      branchId,
      active: active,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<Either<ErrorModel, String>> deleteSchedule(String branchId) async {
    return _dataSource.deleteSchedule(branchId);
  }

  @override
  Future<Either<ErrorModel, (ScheduleEntity, String)>> activateSchedule(
    String branchId,
  ) async {
    final result = await _dataSource.activateSchedule(branchId);
    return result.map((record) => (record.$1, record.$2));
  }

  @override
  Future<Either<ErrorModel, (ScheduleEntity, String)>> deactivateSchedule(
    String branchId,
  ) async {
    final result = await _dataSource.deactivateSchedule(branchId);
    return result.map((record) => (record.$1, record.$2));
  }

  @override
  Future<Either<ErrorModel, List<DayEntity>>> getDaysCatalog() async {
    return _dataSource.getDaysCatalog();
  }

  // ========== Schedule Details Implementation ==========

  @override
  Future<Either<ErrorModel, List<ScheduleDetailEntity>>> getScheduleDetails(
    String branchId,
  ) async {
    final result = await _dataSource.getScheduleDetails(branchId);
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<ErrorModel, ScheduleDetailEntity>> createScheduleDetail(
    String branchId, {
    required int dayOfWeek,
    required String openingTime,
    required String closingTime,
    required bool isClosed,
  }) async {
    final result = await _dataSource.createScheduleDetail(
      branchId,
      dayOfWeek: dayOfWeek,
      openingTime: openingTime,
      closingTime: closingTime,
      isClosed: isClosed,
    );
    return result.map((model) => model.toEntity());
  }

  @override
  Future<Either<ErrorModel, String>> updateScheduleDetail(
    String detailId, {
    required String openingTime,
    required String closingTime,
    required bool isClosed,
  }) async {
    return _dataSource.updateScheduleDetail(
      detailId,
      openingTime: openingTime,
      closingTime: closingTime,
      isClosed: isClosed,
    );
  }

  @override
  Future<Either<ErrorModel, String>> deleteScheduleDetail(
    String detailId,
  ) async {
    return _dataSource.deleteScheduleDetail(detailId);
  }

  // ========== Schedule Exceptions Implementation (HU20-25) ==========

  @override
  Future<Either<ErrorModel, List<ScheduleExceptionEntity>>>
  getScheduleExceptions(String branchId) async {
    final result = await _dataSource.getScheduleExceptions(branchId);
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<ErrorModel, (ScheduleExceptionEntity, String)>>
  createScheduleException(
    String branchId, {
    required String exceptionStartDate,
    String? exceptionEndDate,
    required String openingTime,
    required String closingTime,
    required bool isClosed,
  }) async {
    final result = await _dataSource.createScheduleException(
      branchId,
      exceptionStartDate: exceptionStartDate,
      exceptionEndDate: exceptionEndDate,
      openingTime: openingTime,
      closingTime: closingTime,
      isClosed: isClosed,
    );
    return result.map((record) => (record.$1.toEntity(), record.$2));
  }

  @override
  Future<Either<ErrorModel, String>> updateScheduleException(
    String exceptionId, {
    required String openingTime,
    required String closingTime,
    required bool isClosed,
  }) async {
    return _dataSource.updateScheduleException(
      exceptionId,
      openingTime: openingTime,
      closingTime: closingTime,
      isClosed: isClosed,
    );
  }

  @override
  Future<Either<ErrorModel, String>> deleteScheduleException(
    String exceptionId,
  ) async {
    return _dataSource.deleteScheduleException(exceptionId);
  }

  @override
  Future<Either<ErrorModel, String>> activateScheduleException(
    String exceptionId,
  ) async {
    return _dataSource.activateScheduleException(exceptionId);
  }

  @override
  Future<Either<ErrorModel, String>> deactivateScheduleException(
    String exceptionId,
  ) async {
    return _dataSource.deactivateScheduleException(exceptionId);
  }
}
