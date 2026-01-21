import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/branch_schedules/data/datasources/branch_schedule_datasource.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/day_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_entity.dart';
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
  Future<Either<ErrorModel, ScheduleEntity>> createSchedule(
    String branchId,
  ) async {
    return _dataSource.createSchedule(branchId);
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
  Future<Either<ErrorModel, ScheduleEntity>> activateSchedule(
    String branchId,
  ) async {
    return _dataSource.activateSchedule(branchId);
  }

  @override
  Future<Either<ErrorModel, ScheduleEntity>> deactivateSchedule(
    String branchId,
  ) async {
    return _dataSource.deactivateSchedule(branchId);
  }

  @override
  Future<Either<ErrorModel, List<DayEntity>>> getDaysCatalog() async {
    return _dataSource.getDaysCatalog();
  }
}
