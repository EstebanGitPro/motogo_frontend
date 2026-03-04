import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/service_ratings/data/datasources/service_rating_datasource.dart';
import 'package:motogo_frontend/src/features/service_ratings/data/models/rate_service_request.dart';
import 'package:motogo_frontend/src/features/service_ratings/domain/entities/service_review_entity.dart';
import 'package:motogo_frontend/src/features/service_ratings/domain/repositories/service_rating_repository.dart';

/// Implementation of [ServiceRatingRepository].
///
/// Delegates to [ServiceRatingDataSource] for API communication.
class ServiceRatingRepositoryImpl implements ServiceRatingRepository {
  final ServiceRatingDataSource _dataSource;

  ServiceRatingRepositoryImpl(this._dataSource);

  @override
  Future<Either<ErrorModel, String>> rateServiceItem(
    String completedServiceId,
    String itemId,
    RateServiceRequest request,
  ) {
    return _dataSource.rateServiceItem(completedServiceId, itemId, request);
  }

  @override
  Future<Either<ErrorModel, ServiceReviewSummaryEntity>> getServiceReviews(
    String serviceId,
  ) {
    return _dataSource.getServiceReviews(serviceId);
  }
}
