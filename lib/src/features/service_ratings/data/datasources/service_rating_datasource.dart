import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/datasource_response_mixin.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/features/service_ratings/data/models/rate_service_request.dart';
import 'package:motogo_frontend/src/features/service_ratings/data/models/service_review_model.dart';
import 'package:motogo_frontend/src/features/service_ratings/domain/entities/service_review_entity.dart';

/// DataSource for service rating operations.
///
/// Uses [DataSourceResponseMixin] for standardized response handling.
abstract class ServiceRatingDataSource {
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

class ServiceRatingDataSourceImpl
    with DataSourceResponseMixin
    implements ServiceRatingDataSource {
  final DioClient _dioClient;

  ServiceRatingDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, String>> rateServiceItem(
    String completedServiceId,
    String itemId,
    RateServiceRequest request,
  ) {
    return handleMessageResponse(
      () => _dioClient.post(
        '/completed-services/$completedServiceId/items/$itemId/rating',
        data: request.toJson(),
      ),
      'Calificación registrada exitosamente',
    );
  }

  @override
  Future<Either<ErrorModel, ServiceReviewSummaryEntity>> getServiceReviews(
    String branchId,
    String serviceId,
  ) {
    return handleDataResponse(
      () => _dioClient.get('/branches/$branchId/services/$serviceId/reviews'),
      ServiceReviewSummaryModel.fromJson,
    );
  }
}
