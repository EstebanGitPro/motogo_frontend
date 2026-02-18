import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/entities/completed_service_entity.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/repositories/completed_services_repository.dart';

/// Use case that fetches the service history for a specific motorcycle.
///
/// Calls GET /motorcycles/{motorcycleId}/completed-services and returns
/// a sorted list of completed service entities (most recent first).
class GetMotorcycleHistoryUseCase {
  final CompletedServicesRepository _repository;

  GetMotorcycleHistoryUseCase(this._repository);

  /// Fetches service history for [motorcycleId].
  ///
  /// Returns a list of [CompletedServiceEntity] sorted by request date
  /// descending (most recent first).
  Future<Either<ErrorModel, List<CompletedServiceEntity>>> call(
    String motorcycleId,
  ) async {
    final result = await _repository.getCompletedServicesByMotorcycle(
      motorcycleId,
    );

    return result.map((models) {
      final entities = models.map((m) => m.toEntity()).toList();
      entities.sort((a, b) => b.requestDate.compareTo(a.requestDate));
      return entities;
    });
  }
}
