import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/datasource_response_mixin.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/features/service_ratings/data/models/rating_range_model.dart';

/// DataSource for fetching rating range options from the API.
///
/// Uses [DataSourceResponseMixin] for standardized response handling.
abstract class RatingRangeDataSource {
  /// Fetches the list of available rating ranges.
  Future<Either<ErrorModel, List<RatingRangeModel>>> getRatingRanges();
}

class RatingRangeDataSourceImpl
    with DataSourceResponseMixin
    implements RatingRangeDataSource {
  final DioClient _dioClient;

  RatingRangeDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, List<RatingRangeModel>>> getRatingRanges() {
    return handleListResponse(
      () => _dioClient.get('/rating-ranges'),
      (json) => RatingRangeModel.fromJson(json),
      listKey: 'ratings',
    );
  }
}
