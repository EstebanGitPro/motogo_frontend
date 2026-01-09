import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/constants/error_codes.dart';
import 'package:motogo_frontend/src/core/errors/error_messages.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';

/// DataSource for obtaining Firebase custom tokens from the backend.
///
/// Uses DioClient with automatic token refresh.
abstract class FirebaseTokenDataSource {
  /// Gets a Firebase custom token from the backend.
  /// Requires the user to be authenticated with Keycloak.
  Future<Either<ErrorModel, String>> getFirebaseToken();
}

class FirebaseTokenDataSourceImpl implements FirebaseTokenDataSource {
  final DioClient _dioClient;

  FirebaseTokenDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, String>> getFirebaseToken() async {
    try {
      final response = await _dioClient.get('/auth/firebase-token');
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        // Extract firebase_token from response
        final data = responseData['data'] as Map<String, dynamic>?;
        final firebaseToken = data?['firebase_token'] as String?;

        if (firebaseToken != null && firebaseToken.isNotEmpty) {
          return Right(firebaseToken);
        }

        return Left(
          ErrorModel(
            message:
                responseData['message']?.toString() ??
                FallbackMessages.invalidResponse,
            errorCode: ErrorCodes.firebaseTokenMissing,
          ),
        );
      }

      return Left(
        ErrorModel(
          message: FallbackMessages.invalidResponse,
          errorCode: ErrorCodes.emptyResponse,
        ),
      );
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }
}
