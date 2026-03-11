import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/service_ratings/data/models/rate_service_request.dart';
import 'package:motogo_frontend/src/features/service_ratings/domain/entities/service_review_entity.dart';

/// Repository contract for service rating operations.
abstract class ServiceRatingRepository {
  /// Rates a specific service item within a completed service.
  Future<Either<ErrorModel, String>> rateServiceItem(
    String completedServiceId,
    String itemId,
    RateServiceRequest request,
  );

  /// Fetches all reviews for a specific service type scoped by branch.
  Future<Either<ErrorModel, ServiceReviewSummaryEntity>> getServiceReviews(
    String branchId,
    String serviceId,
  );
}
