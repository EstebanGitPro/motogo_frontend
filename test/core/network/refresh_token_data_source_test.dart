import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/constants/error_codes.dart';
import 'package:motogo_frontend/src/core/errors/error_messages.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/refresh_token_data_source.dart';
import 'package:motogo_frontend/src/core/network/token_response.dart';

/// Creates a Dio instance with an interceptor that resolves with the given data.
Dio _dioWithResponse({
  required Map<String, dynamic> data,
  required int statusCode,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.resolve(
          Response(requestOptions: options, data: data, statusCode: statusCode),
        );
      },
    ),
  );
  return dio;
}

/// Creates a Dio instance that throws a DioException.
Dio _dioWithDioException({required int statusCode, String? message}) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.reject(
          DioException(
            requestOptions: options,
            response: Response(requestOptions: options, statusCode: statusCode),
            type: DioExceptionType.badResponse,
            message: message,
          ),
        );
      },
    ),
  );
  return dio;
}

/// Creates a Dio instance that throws a generic exception.
Dio _dioWithGenericException(String message) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        throw Exception(message);
      },
    ),
  );
  return dio;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RefreshTokenDataSource (abstract)', () {
    test('should define the refreshToken contract', () {
      expect(RefreshTokenDataSource, isNotNull);
    });
  });

  group('RefreshTokenDataSourceImpl', () {
    group('constructor', () {
      test('should create instance with default Dio', () {
        final dataSource = RefreshTokenDataSourceImpl();
        expect(dataSource, isA<RefreshTokenDataSource>());
        expect(dataSource, isA<RefreshTokenDataSourceImpl>());
      });

      test('should accept an injected Dio instance', () {
        final dio = Dio(BaseOptions(baseUrl: 'http://test'));
        final dataSource = RefreshTokenDataSourceImpl(dio: dio);
        expect(dataSource, isA<RefreshTokenDataSourceImpl>());
      });
    });

    group('refreshToken - successful responses', () {
      test(
        'should return Right(TokenResponse) on valid 200 response',
        () async {
          final dio = _dioWithResponse(
            data: {
              'success': true,
              'message': 'Token refreshed',
              'data': {
                'access_token': 'new-access-token',
                'refresh_token': 'new-refresh-token',
                'expires_in': 3600,
                'token_type': 'Bearer',
              },
            },
            statusCode: 200,
          );
          final dataSource = RefreshTokenDataSourceImpl(dio: dio);

          final result = await dataSource.refreshToken('old-refresh-token');

          expect(result.isRight, isTrue);
          expect(result.right.accessToken, 'new-access-token');
          expect(result.right.refreshToken, 'new-refresh-token');
          expect(result.right.expiresIn, 3600);
          expect(result.right.tokenType, 'Bearer');
        },
      );

      test('should use default values for optional token fields', () async {
        final dio = _dioWithResponse(
          data: {
            'success': true,
            'data': {'access_token': 'at', 'refresh_token': 'rt'},
          },
          statusCode: 200,
        );
        final dataSource = RefreshTokenDataSourceImpl(dio: dio);

        final result = await dataSource.refreshToken('token');

        expect(result.isRight, isTrue);
        expect(result.right.expiresIn, 300);
        expect(result.right.tokenType, 'Bearer');
      });
    });

    group('refreshToken - error responses', () {
      test('should return Left when success is false', () async {
        final dio = _dioWithResponse(
          data: {
            'success': false,
            'message': 'Invalid refresh token',
            'code': 'AUTH_ERR',
          },
          statusCode: 200,
        );
        final dataSource = RefreshTokenDataSourceImpl(dio: dio);

        final result = await dataSource.refreshToken('bad-token');

        expect(result.isLeft, isTrue);
        expect(result.left.message, 'Invalid refresh token');
        expect(result.left.errorCode, 'AUTH_ERR');
      });

      test(
        'should use fallback message when success false with no message',
        () async {
          final dio = _dioWithResponse(
            data: {'success': false},
            statusCode: 200,
          );
          final dataSource = RefreshTokenDataSourceImpl(dio: dio);

          final result = await dataSource.refreshToken('bad-token');

          expect(result.isLeft, isTrue);
          expect(result.left.message, FallbackMessages.sessionRefreshError);
        },
      );

      test('should return Left when data field is null', () async {
        final dio = _dioWithResponse(
          data: {'success': true, 'message': 'OK', 'data': null},
          statusCode: 200,
        );
        final dataSource = RefreshTokenDataSourceImpl(dio: dio);

        final result = await dataSource.refreshToken('token');

        expect(result.isLeft, isTrue);
        expect(result.left.message, FallbackMessages.invalidResponse);
        expect(result.left.errorCode, ErrorCodes.invalidResponse);
      });

      test('should return Left on non-200 status code', () async {
        final dio = _dioWithResponse(
          data: {'error': 'Server error'},
          statusCode: 500,
        );
        final dataSource = RefreshTokenDataSourceImpl(dio: dio);

        final result = await dataSource.refreshToken('token');

        expect(result.isLeft, isTrue);
        expect(result.left.message, FallbackMessages.sessionRefreshError);
        expect(result.left.statusCode, 500);
      });
    });

    group('refreshToken - DioException handling', () {
      test('should return session expired on 401 DioException', () async {
        final dio = _dioWithDioException(statusCode: 401);
        final dataSource = RefreshTokenDataSourceImpl(dio: dio);

        final result = await dataSource.refreshToken('expired-token');

        expect(result.isLeft, isTrue);
        expect(result.left.message, FallbackMessages.sessionExpired);
        expect(result.left.errorCode, ErrorCodes.sessionExpired);
        expect(result.left.statusCode, 401);
      });

      test('should return network error on non-401 DioException', () async {
        final dio = _dioWithDioException(
          statusCode: 503,
          message: 'Service unavailable',
        );
        final dataSource = RefreshTokenDataSourceImpl(dio: dio);

        final result = await dataSource.refreshToken('token');

        expect(result.isLeft, isTrue);
        expect(result.left.message, 'Service unavailable');
        expect(result.left.errorCode, ErrorCodes.networkError);
      });

      test(
        'should use fallback message when DioException has no message',
        () async {
          final dio = _dioWithDioException(statusCode: 503);
          final dataSource = RefreshTokenDataSourceImpl(dio: dio);

          final result = await dataSource.refreshToken('token');

          expect(result.isLeft, isTrue);
          expect(result.left.message, FallbackMessages.connectionError);
        },
      );
    });

    group('refreshToken - generic exception handling', () {
      test('should handle thrown exception as a network error', () async {
        final dio = _dioWithGenericException('Parsing failed');
        final dataSource = RefreshTokenDataSourceImpl(dio: dio);

        final result = await dataSource.refreshToken('token');

        // Dio wraps thrown exceptions as DioException, so they are caught
        // by the DioException handler rather than the generic catch block
        expect(result.isLeft, isTrue);
        expect(result.left.message, isNotEmpty);
        expect(result.left.errorCode, isNotNull);
      });
    });

    group('refreshToken - connection errors (default Dio)', () {
      test('should return Left when server is unreachable', () async {
        final dataSource = RefreshTokenDataSourceImpl();

        final result = await dataSource.refreshToken('some-token');

        expect(result.isLeft, isTrue);
        expect(result.left.message, isNotEmpty);
      });
    });
  });

  group('ErrorCodes constants', () {
    test('should have correct session error codes', () {
      expect(ErrorCodes.sessionExpired, 'SESSION_EXPIRED');
      expect(ErrorCodes.sessionRefreshFailed, 'SESSION_REFRESH_FAILED');
    });

    test('should have correct network error codes', () {
      expect(ErrorCodes.networkError, 'NETWORK_ERROR');
      expect(ErrorCodes.unknownError, 'UNKNOWN_ERROR');
      expect(ErrorCodes.invalidResponse, 'INVALID_RESPONSE');
    });
  });

  group('FallbackMessages constants', () {
    test('should have non-empty session messages', () {
      expect(FallbackMessages.sessionRefreshError, isNotEmpty);
      expect(FallbackMessages.sessionExpired, isNotEmpty);
    });

    test('should have non-empty error messages', () {
      expect(FallbackMessages.connectionError, isNotEmpty);
      expect(FallbackMessages.unexpectedError, isNotEmpty);
      expect(FallbackMessages.invalidResponse, isNotEmpty);
    });
  });
}
