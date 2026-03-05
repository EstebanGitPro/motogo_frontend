import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/geocoding/data/models/geocoding_result_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';

/// DataSource for geocoding operations.
///
/// Calls the backend geocoding API to convert addresses to coordinates.
abstract class GeocodingDataSource {
  /// Geocode an address to get latitude/longitude coordinates.
  Future<Either<ErrorModel, GeocodingResultModel>> geocode({
    required String address,
    required String cityName,
    required String departmentName,
  });
}

class GeocodingDataSourceImpl implements GeocodingDataSource {
  final DioClient _dioClient;

  GeocodingDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, GeocodingResultModel>> geocode({
    required String address,
    required String cityName,
    required String departmentName,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/location/geocode',
        data: {
          'address': address,
          'city_name': cityName,
          'department_name': departmentName,
        },
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }
        if (success == true) {
          return Right(GeocodingResultModel.fromJson(responseData));
        }
      }

      return Left(
        DioErrorHandler.fromBackendError({'message': responseData?.toString()}),
      );
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }
}
