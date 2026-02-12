import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/branch_detail/domain/entities/branch_detail_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_detail_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_exception_entity.dart';
import 'package:motogo_frontend/src/features/branch_services/domain/entities/branch_service_entity.dart';

/// Repository interface for branch detail operations.
///
/// Defines the contract for fetching branch information.
abstract class BranchDetailRepository {
  /// Fetches the basic branch detail.
  Future<Either<ErrorModel, BranchDetailEntity>> getDetail(String branchId);

  /// Fetches the services associated with the branch.
  Future<Either<ErrorModel, List<BranchServiceEntity>>> getServices(
    String branchId,
  );

  /// Fetches the schedule details for the branch.
  Future<Either<ErrorModel, List<ScheduleDetailEntity>>> getSchedules(
    String branchId,
  );

  /// Fetches the schedule exceptions for the branch.
  Future<Either<ErrorModel, List<ScheduleExceptionEntity>>> getExceptions(
    String branchId,
  );
}
