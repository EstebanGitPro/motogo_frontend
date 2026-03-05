import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/config/config.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';

/// DataSource for email recovery verification.
///
/// Uses its own Dio instance because this is a public endpoint (no auth required).
class EmailRecoveryVerificationDataSource {
  final Dio _dio;

  EmailRecoveryVerificationDataSource({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: Config.baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: {'Content-Type': 'application/json'},
            ),
          );

  Future<Either<ErrorModel, bool>> verifyEmail(String email) async {
    try {
      final response = await _dio.post(
        '/auth/password-reset',
        data: {'email': email},
      );

      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final status = responseData['status'] as String?;
        if (status == 'success' || success == true) {
          return const Right(true);
        }

        return Left(DioErrorHandler.fromBackendError(responseData));
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
