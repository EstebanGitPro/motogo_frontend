import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/data/models/motorcycle_model.dart';

/// DataSource for motorcycle editing operations.
///
/// Uses DioClient with automatic token refresh.
abstract class EditMotorcycleDataSource {
  /// Updates an existing motorcycle.
  ///
  /// Returns [Right] with the success message on success,
  /// or [Left] with [ErrorModel] on failure.
  Future<Either<ErrorModel, String>> updateMotorcycle(
    String id,
    MotorcycleModel motorcycle,
  );
}

class EditMotorcycleDataSourceImpl implements EditMotorcycleDataSource {
  final DioClient _dioClient;

  EditMotorcycleDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, String>> updateMotorcycle(
    String id,
    MotorcycleModel motorcycle,
  ) async {
    try {
      final body = motorcycle.toJson();

      // TODO: Remove after debugging
      debugPrint('🏍️ [EditMotoDS] PUT /motorcycles/$id body: $body');

      final response = await _dioClient.put('/motorcycles/$id', data: body);
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        // Check for success flag
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final message =
            responseData['message'] as String? ??
            'Motocicleta actualizada exitosamente';
        return Right(message);
      }

      return const Right('Motocicleta actualizada exitosamente');
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }
}
