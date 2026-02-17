import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/completed_services/data/model/status_transition_model.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/repositories/completed_services_repository.dart';

/// Use case for fetching transitions history of a completed service.
///
/// Calls GET /completed-services/{id}/transitions via the repository.
class GetServiceTransitionsUseCase {
  final CompletedServicesRepository _repository;

  GetServiceTransitionsUseCase(this._repository);

  Future<Either<ErrorModel, List<StatusTransitionModel>>> call(
    String serviceId,
  ) {
    return _repository.getServiceTransitions(serviceId);
  }
}
