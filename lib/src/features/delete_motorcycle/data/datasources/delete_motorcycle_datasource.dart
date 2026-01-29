import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_messages.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';

/// DataSource for motorcycle deletion operations.
///
/// Uses DioClient with automatic token refresh.
abstract class DeleteMotorcycleDataSource {
  /// Deletes a motorcycle by its ID.
  ///
  /// Returns [Right] with the success message on success,
  /// or [Left] with [ErrorModel] on failure.
  Future<Either<ErrorModel, String>> deleteMotorcycle(String id);
}

class DeleteMotorcycleDataSourceImpl implements DeleteMotorcycleDataSource {
  final DioClient _dioClient;

  DeleteMotorcycleDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, String>> deleteMotorcycle(String id) async {
    try {
      final response = await _dioClient.delete('/motorcycles/$id');
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        // Check for success flag
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        // Extract message from backend
        final message =
            responseData['message'] as String? ??
            FallbackMessages.operationSuccess;
        return Right(message);
      }
      return const Right(FallbackMessages.operationSuccess);
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }
}
