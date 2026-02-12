import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/branch_detail/data/datasources/branch_detail_datasource.dart';
import 'package:motogo_frontend/src/features/branch_detail/domain/entities/branch_detail_entity.dart';
import 'package:motogo_frontend/src/features/branch_detail/domain/repositories/branch_detail_repository.dart';
import 'package:motogo_frontend/src/features/branch_schedules/data/datasources/branch_schedule_datasource.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_detail_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_exception_entity.dart';
import 'package:motogo_frontend/src/features/branch_services/data/datasources/branch_services_datasource.dart';
import 'package:motogo_frontend/src/features/branch_services/domain/entities/branch_service_entity.dart';

/// Implementation of [BranchDetailRepository].
///
/// Orchestrates data fetching from multiple datasources.
class BranchDetailRepositoryImpl implements BranchDetailRepository {
  final BranchDetailDataSource _detailDataSource;
  final BranchServicesDataSource _servicesDataSource;
  final BranchScheduleDataSource _scheduleDataSource;

  BranchDetailRepositoryImpl({
    required BranchDetailDataSource detailDataSource,
    required BranchServicesDataSource servicesDataSource,
    required BranchScheduleDataSource scheduleDataSource,
  }) : _detailDataSource = detailDataSource,
       _servicesDataSource = servicesDataSource,
       _scheduleDataSource = scheduleDataSource;

  @override
  Future<Either<ErrorModel, BranchDetailEntity>> getDetail(
    String branchId,
  ) async {
    final result = await _detailDataSource.getBranchDetail(branchId);
    return result.map((model) => model.toEntity());
  }

  @override
  Future<Either<ErrorModel, List<BranchServiceEntity>>> getServices(
    String branchId,
  ) async {
    final result = await _servicesDataSource.getBranchServices(branchId);
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<ErrorModel, List<ScheduleDetailEntity>>> getSchedules(
    String branchId,
  ) async {
    final result = await _scheduleDataSource.getScheduleDetails(branchId);
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<ErrorModel, List<ScheduleExceptionEntity>>> getExceptions(
    String branchId,
  ) async {
    final result = await _scheduleDataSource.getScheduleExceptions(branchId);
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }
}
