import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';
import 'package:motogo_frontend/src/core/config/config.dart';
import 'package:motogo_frontend/src/core/constants/error_codes.dart';
import 'package:motogo_frontend/src/core/errors/error_messages.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/token_response.dart';

import 'dio_client_stub.dart'
    if (dart.library.html) 'dio_client_web.dart'
    as web_adapter;

/// DataSource for refreshing access tokens.
///
/// Uses a separate Dio instance without interceptors to avoid
/// infinite loops when the main client gets a 401.
abstract class RefreshTokenDataSource {
  /// Attempts to refresh the access token using the provided refresh token.
  ///
  /// Returns [TokenResponse] on success, or [ErrorModel] on failure.
  Future<Either<ErrorModel, TokenResponse>> refreshToken(String refreshToken);
}

class RefreshTokenDataSourceImpl implements RefreshTokenDataSource {
  // Use a separate Dio instance without auth interceptor
  // to avoid infinite refresh loops
  late final Dio _dio;

  RefreshTokenDataSourceImpl({Dio? dio}) {
    _dio =
        dio ??
        Dio(
          BaseOptions(
            baseUrl: Config.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {'Content-Type': 'application/json'},
            extra: kIsWeb ? {'withCredentials': true} : {},
          ),
        );

    // Configure BrowserHttpClientAdapter for Web cookie support.
    // The mg_refresh_token cookie is restricted to /motogo/api/v1/auth path,
    // so it only travels on refresh/logout requests.
    if (kIsWeb && dio == null) {
      web_adapter.configureWebCredentials(_dio);
    }
  }

  @override
  Future<Either<ErrorModel, TokenResponse>> refreshToken(
    String refreshToken,
  ) async {
    try {
      // On Web, the refresh token travels as an HttpOnly cookie.
      // The backend reads it from the cookie if body is empty.
      // On mobile, send the refresh token in the request body.
      final response = await _dio.post(
        '/auth/refresh',
        data: kIsWeb ? null : {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic>) {
          final success = responseData['success'] as bool?;
          if (success == false) {
            return Left(
              ErrorModel(
                message:
                    responseData['message']?.toString() ??
                    FallbackMessages.sessionRefreshError,
                errorCode: responseData['code']?.toString(),
              ),
            );
          }

          final data = responseData['data'] as Map<String, dynamic>?;
          if (data != null) {
            return Right(TokenResponse.fromJson(data));
          }
        }

        return Left(
          ErrorModel(
            message: FallbackMessages.invalidResponse,
            errorCode: ErrorCodes.invalidResponse,
          ),
        );
      }

      return Left(
        ErrorModel(
          message: FallbackMessages.sessionRefreshError,
          errorCode: response.statusCode.toString(),
          statusCode: response.statusCode,
        ),
      );
    } on DioException catch (e) {
      // 401 means refresh token is expired/invalid
      if (e.response?.statusCode == 401) {
        return Left(
          ErrorModel(
            message: FallbackMessages.sessionExpired,
            errorCode: ErrorCodes.sessionExpired,
            statusCode: 401,
          ),
        );
      }

      return Left(
        ErrorModel(
          message: e.message ?? FallbackMessages.connectionError,
          errorCode: ErrorCodes.networkError,
        ),
      );
    } catch (e) {
      return Left(
        ErrorModel(
          message: '${FallbackMessages.unexpectedError}: $e',
          errorCode: ErrorCodes.unknownError,
        ),
      );
    }
  }
}
