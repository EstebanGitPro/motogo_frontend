import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/constants/person_constants.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';

/// DataSource for person deletion operations.
///
/// Uses DioClient with automatic token refresh.
abstract class DeletePersonDataSource {
  /// Deletes the authenticated user's account.
  ///
  /// Returns [Right] with success message on success,
  /// or [Left] with [ErrorModel] on failure.
  Future<Either<ErrorModel, String>> deleteAccount();
}

class DeletePersonDataSourceImpl implements DeletePersonDataSource {
  final DioClient _dioClient;

  DeletePersonDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, String>> deleteAccount() async {
    try {
      final response = await _dioClient.delete('/persons/me');
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }
        // Return message from backend or default
        final message =
            responseData['message'] as String? ??
            PersonConstants.deleteAccountFallbackSuccess;
        return Right(message);
      }
      return const Right(PersonConstants.deleteAccountFallbackSuccess);
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }
}
