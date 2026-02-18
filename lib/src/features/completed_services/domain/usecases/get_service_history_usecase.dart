import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/entities/completed_service_entity.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/repositories/completed_services_repository.dart';

/// Use case that fetches the service history for a motorcycle.
///
/// Fetches completed services from each branch in parallel,
/// filters by motorcycle_id, and returns a combined sorted list
/// (most recent first).
class GetServiceHistoryUseCase {
  final CompletedServicesRepository _repository;

  GetServiceHistoryUseCase(this._repository);

  /// Fetches service history for [motorcycleId] from [branchIds].
  ///
  /// Returns a list of [CompletedServiceEntity] sorted by request date
  /// descending. Silently skips branches that fail to load.
  Future<Either<ErrorModel, List<CompletedServiceEntity>>> call({
    required String motorcycleId,
    required List<String> branchIds,
  }) async {
    if (branchIds.isEmpty) {
      return const Right([]);
    }

    try {
      // Fetch from all branches in parallel
      final futures = branchIds.map(
        (branchId) => _repository.getCompletedServicesByBranch(branchId),
      );
      final results = await Future.wait(futures);

      // Collect all services, skipping branches that errored
      final allServices = <CompletedServiceEntity>[];
      for (final result in results) {
        result.fold(
          (_) {
            // Skip branches that fail — partial results are acceptable
          },
          (models) {
            allServices.addAll(
              models
                  .where((m) => m.motorcycleId == motorcycleId)
                  .map((m) => m.toEntity()),
            );
          },
        );
      }

      // Sort by request date descending (most recent first)
      allServices.sort((a, b) => b.requestDate.compareTo(a.requestDate));

      return Right(allServices);
    } catch (e) {
      return Left(
        ErrorModel(
          errorCode: 'SERVICE_HISTORY_ERROR',
          message: 'Error al obtener el historial de servicios',
        ),
      );
    }
  }
}
