import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/service_ratings/data/models/rate_service_request.dart';
import 'package:motogo_frontend/src/features/service_ratings/domain/repositories/service_rating_repository.dart';

/// Use case for rating a specific service item within a completed service.
///
/// Calls POST /completed-services/{id}/items/{itemId}/rating via the repository.
class RateServiceItemUseCase {
  final ServiceRatingRepository _repository;

  RateServiceItemUseCase(this._repository);

  Future<Either<ErrorModel, String>> call(
    String completedServiceId,
    String itemId,
    RateServiceRequest request,
  ) {
    return _repository.rateServiceItem(completedServiceId, itemId, request);
  }
}
