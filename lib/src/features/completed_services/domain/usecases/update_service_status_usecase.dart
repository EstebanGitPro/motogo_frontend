import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/repositories/completed_services_repository.dart';

/// Use case for updating the status of a completed service.
///
/// Calls PATCH /completed-services/{id}/status via the repository.
class UpdateServiceStatusUseCase {
  final CompletedServicesRepository _repository;

  UpdateServiceStatusUseCase(this._repository);

  Future<Either<ErrorModel, String>> call(String serviceId, String newStatus) {
    return _repository.updateServiceStatus(serviceId, newStatus);
  }
}
