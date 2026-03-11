import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/service_ratings/domain/entities/service_review_entity.dart';
import 'package:motogo_frontend/src/features/service_ratings/domain/repositories/service_rating_repository.dart';

/// Fetches the review summary for a specific service type scoped by branch.
class GetServiceReviewsUseCase {
  final ServiceRatingRepository _repository;

  GetServiceReviewsUseCase(this._repository);

  Future<Either<ErrorModel, ServiceReviewSummaryEntity>> call(
    String branchId,
    String serviceId,
  ) {
    return _repository.getServiceReviews(branchId, serviceId);
  }
}
