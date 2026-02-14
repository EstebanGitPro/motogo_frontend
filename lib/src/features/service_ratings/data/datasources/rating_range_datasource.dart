import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';
import 'package:motogo_frontend/src/features/service_ratings/data/models/rating_range_model.dart';

/// DataSource for fetching rating range options from the API.
///
/// Handles the retrieval of allowed rating values and labels.
abstract class RatingRangeDataSource {
  /// Fetches the list of available rating ranges.
  Future<Either<ErrorModel, List<RatingRangeModel>>> getRatingRanges();
}

class RatingRangeDataSourceImpl implements RatingRangeDataSource {
  final DioClient _dioClient;

  RatingRangeDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, List<RatingRangeModel>>> getRatingRanges() async {
    try {
      final response = await _dioClient.get('/rating-ranges');
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final data = responseData['data'] as Map<String, dynamic>?;

        if (data != null) {
          final ratingsList = data['ratings'] as List<dynamic>?;

          if (ratingsList != null) {
            final ratings = ratingsList
                .map(
                  (json) =>
                      RatingRangeModel.fromJson(json as Map<String, dynamic>),
                )
                .toList();
            return Right(ratings);
          }
        }
        return const Right([]);
      }
      return const Right([]);
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }
}
