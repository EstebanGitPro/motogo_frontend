import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/repositories/completed_services_repository.dart';

/// Use case for deleting a completed service (HU65).
///
/// Calls DELETE /completed-services/{id} via the repository.
class DeleteCompletedServiceUseCase {
  final CompletedServicesRepository _repository;

  DeleteCompletedServiceUseCase(this._repository);

  Future<Either<ErrorModel, String>> call(String serviceId) {
    return _repository.deleteCompletedService(serviceId);
  }
}
