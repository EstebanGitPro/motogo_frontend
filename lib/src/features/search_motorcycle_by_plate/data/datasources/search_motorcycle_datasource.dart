import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/data/models/motorcycle_detail_model.dart';

/// DataSource for searching motorcycles by license plate.
///
/// Uses DioClient with automatic token refresh.
abstract class SearchMotorcycleDataSource {
  /// Searches for a motorcycle by its license plate.
  ///
  /// Returns motorcycle details including reference info.
  Future<Either<ErrorModel, MotorcycleDetailModel>> searchByPlate(String plate);
}

class SearchMotorcycleDataSourceImpl implements SearchMotorcycleDataSource {
  final DioClient _dioClient;

  SearchMotorcycleDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, MotorcycleDetailModel>> searchByPlate(
    String plate,
  ) async {
    try {
      final response = await _dioClient.get(
        '/motorcycles/lookup',
        queryParameters: {'plate': plate},
      );
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        // Parse motorcycle from 'data' field
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          final motorcycle = MotorcycleDetailModel.fromJson(data);
          return Right(motorcycle);
        }

        return Left(
          ErrorModel(
            message: 'No se encontró información de la motocicleta',
            errorCode: 'PARSE_ERROR',
          ),
        );
      }

      return Left(
        ErrorModel(
          message: 'Respuesta inválida del servidor',
          errorCode: 'INVALID_RESPONSE',
        ),
      );
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }
}
