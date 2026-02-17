import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/completed_services/data/model/register_completed_service_model.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/repositories/completed_services_repository.dart';

/// Use case for registering a completed service.
///
/// Delegates to [CompletedServicesRepository].
class RegisterCompletedServiceUseCase {
  final CompletedServicesRepository _repository;

  RegisterCompletedServiceUseCase(this._repository);

  /// Registers a completed service with the given request data.
  Future<Either<ErrorModel, String>> call(
    RegisterCompletedServiceModel request,
  ) {
    return _repository.registerCompletedService(request);
  }
}
