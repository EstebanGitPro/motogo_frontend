import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/data/models/motorcycle_model.dart';

/// DataSource for motorcycle operations.
///
/// Handles REST API communication for motorcycle CRUD operations.
/// Requires MOTORCYCLIST role for registration.
abstract class MotorcycleDataSource {
  /// Registers a new motorcycle for the current user.
  /// Endpoint: POST /motorcycles
  Future<Either<ErrorModel, String>> registerMotorcycle(MotorcycleModel model);
}

class MotorcycleDataSourceImpl implements MotorcycleDataSource {
  final DioClient _dioClient;

  MotorcycleDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, String>> registerMotorcycle(
    MotorcycleModel model,
  ) async {
    try {
      final response = await _dioClient.post(
        '/motorcycles',
        data: model.toJson(),
      );
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        // Return success message from backend (following Success Message Hydration pattern)
        final message =
            responseData['message'] as String? ??
            'Motocicleta registrada exitosamente';
        return Right(message);
      }

      return const Right('Motocicleta registrada exitosamente');
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }
}
