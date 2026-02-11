import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/branch_detail/domain/entities/branch_detail_entity.dart';
import 'package:motogo_frontend/src/features/branch_detail/domain/repositories/branch_detail_repository.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_detail_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_exception_entity.dart';
import 'package:motogo_frontend/src/features/branch_services/domain/entities/branch_service_entity.dart';

/// Combined result containing all branch detail data.
class BranchFullDetail extends Equatable {
  final BranchDetailEntity detail;
  final List<BranchServiceEntity> services;
  final List<ScheduleDetailEntity> schedules;
  final List<ScheduleExceptionEntity> exceptions;
  final bool isOpenNow;

  const BranchFullDetail({
    required this.detail,
    required this.services,
    required this.schedules,
    required this.exceptions,
    required this.isOpenNow,
  });

  @override
  List<Object?> get props => [
    detail,
    services,
    schedules,
    exceptions,
    isOpenNow,
  ];
}

/// Use case for fetching complete branch detail.
///
/// Loads detail, services, schedules, and exceptions in parallel.
class GetBranchDetailUseCase {
  final BranchDetailRepository _repository;

  GetBranchDetailUseCase(this._repository);

  /// Fetches all branch data in parallel.
  ///
  /// Returns [BranchFullDetail] with all data, or [ErrorModel] if
  /// the main detail fails. Services, schedules, and exceptions failures
  /// are handled gracefully with empty lists.
  Future<Either<ErrorModel, BranchFullDetail>> call(String branchId) async {
    // Load all data in parallel
    final results = await Future.wait([
      _repository.getDetail(branchId),
      _repository.getServices(branchId),
      _repository.getSchedules(branchId),
      _repository.getExceptions(branchId),
    ]);

    final detailResult = results[0] as Either<ErrorModel, BranchDetailEntity>;
    final servicesResult =
        results[1] as Either<ErrorModel, List<BranchServiceEntity>>;
    final schedulesResult =
        results[2] as Either<ErrorModel, List<ScheduleDetailEntity>>;
    final exceptionsResult =
        results[3] as Either<ErrorModel, List<ScheduleExceptionEntity>>;

    // If detail fails, return error
    if (detailResult.isLeft) {
      return Left(detailResult.left);
    }

    final detail = detailResult.right;

    // Services, schedules, and exceptions are optional - use empty lists on failure
    final services = servicesResult.isRight
        ? servicesResult.right
        : <BranchServiceEntity>[];
    final schedules = schedulesResult.isRight
        ? schedulesResult.right
        : <ScheduleDetailEntity>[];
    final exceptions = exceptionsResult.isRight
        ? exceptionsResult.right
        : <ScheduleExceptionEntity>[];

    // Calculate if currently open (considering exceptions)
    final isOpenNow = detail.isOpenNow(schedules, exceptions);

    return Right(
      BranchFullDetail(
        detail: detail,
        services: services,
        schedules: schedules,
        exceptions: exceptions,
        isOpenNow: isOpenNow,
      ),
    );
  }
}
