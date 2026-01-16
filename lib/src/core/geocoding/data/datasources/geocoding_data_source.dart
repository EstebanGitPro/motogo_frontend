import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/constants/debug_messages.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/geocoding/data/models/geocoding_result_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';

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

      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        return Right(GeocodingResultModel.fromJson(data));
      }

      return Left(ErrorModel(message: DebugMessages.geocodingFailed));
    } on DioException catch (e) {
      // Extract message from DioException response data if available
      String errorMessage = DebugMessages.geocodingFailed;
      if (e.response?.data is Map<String, dynamic>) {
        final data = e.response!.data as Map<String, dynamic>;
        errorMessage = data['message'] as String? ?? errorMessage;
      }
      return Left(ErrorModel(message: errorMessage));
    } catch (e) {
      return Left(ErrorModel(message: DebugMessages.unexpectedError));
    }
  }
}
