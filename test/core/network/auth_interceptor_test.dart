import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/auth_interceptor.dart';
import 'package:motogo_frontend/src/core/network/refresh_token_data_source.dart';
import 'package:motogo_frontend/src/core/network/token_response.dart';

import 'auth_interceptor_test.mocks.dart';

@GenerateMocks([RefreshTokenDataSource])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Provide dummy value for Either type
  setUpAll(() {
    provideDummy<Either<ErrorModel, TokenResponse>>(
      Left(ErrorModel(message: 'dummy error')),
    );
  });

  late AuthInterceptor interceptor;
  late MockRefreshTokenDataSource mockRefreshDataSource;

  setUp(() {
    mockRefreshDataSource = MockRefreshTokenDataSource();
    interceptor = AuthInterceptor(mockRefreshDataSource);
  });

  group('AuthInterceptor', () {
    group('constructor', () {
      test('should create with RefreshTokenDataSource', () {
        expect(interceptor, isA<AuthInterceptor>());
        expect(interceptor, isA<Interceptor>());
      });
    });

    group('onError - non-401 errors', () {
      test('should pass through 500 errors without refresh attempt', () {
        final options = RequestOptions(path: '/test');
        final response = Response(requestOptions: options, statusCode: 500);
        final error = DioException(
          requestOptions: options,
          response: response,
          type: DioExceptionType.badResponse,
        );
        final handler = _MockErrorInterceptorHandler();

        interceptor.onError(error, handler);

        expect(handler.nextCalled, isTrue);
        expect(handler.lastError, error);
      });

      test('should pass through 400 errors without refresh attempt', () {
        final options = RequestOptions(path: '/test');
        final response = Response(requestOptions: options, statusCode: 400);
        final error = DioException(
          requestOptions: options,
          response: response,
          type: DioExceptionType.badResponse,
        );
        final handler = _MockErrorInterceptorHandler();

        interceptor.onError(error, handler);

        expect(handler.nextCalled, isTrue);
      });

      test('should pass through 404 errors without refresh attempt', () {
        final options = RequestOptions(path: '/test');
        final response = Response(requestOptions: options, statusCode: 404);
        final error = DioException(
          requestOptions: options,
          response: response,
          type: DioExceptionType.badResponse,
        );
        final handler = _MockErrorInterceptorHandler();

        interceptor.onError(error, handler);

        expect(handler.nextCalled, isTrue);
      });

      test('should pass through 403 errors without refresh attempt', () {
        final options = RequestOptions(path: '/test');
        final response = Response(requestOptions: options, statusCode: 403);
        final error = DioException(
          requestOptions: options,
          response: response,
          type: DioExceptionType.badResponse,
        );
        final handler = _MockErrorInterceptorHandler();

        interceptor.onError(error, handler);

        expect(handler.nextCalled, isTrue);
      });
    });

    group('onError - 401 handling for auth endpoints', () {
      test('should skip refresh for login endpoint on 401', () {
        final options = RequestOptions(path: '/auth/login');
        final response = Response(requestOptions: options, statusCode: 401);
        final error = DioException(
          requestOptions: options,
          response: response,
          type: DioExceptionType.badResponse,
        );
        final handler = _MockErrorInterceptorHandler();

        interceptor.onError(error, handler);

        expect(handler.nextCalled, isTrue);
      });

      test('should skip refresh for refresh endpoint on 401', () {
        final options = RequestOptions(path: '/auth/refresh');
        final response = Response(requestOptions: options, statusCode: 401);
        final error = DioException(
          requestOptions: options,
          response: response,
          type: DioExceptionType.badResponse,
        );
        final handler = _MockErrorInterceptorHandler();

        interceptor.onError(error, handler);

        expect(handler.nextCalled, isTrue);
      });
    });

    group('mock configuration', () {
      test('should properly mock successful token refresh', () async {
        final tokenResponse = TokenResponse(
          accessToken: 'new-access-token',
          refreshToken: 'new-refresh-token',
          expiresIn: 3600,
          tokenType: 'Bearer',
        );

        when(
          mockRefreshDataSource.refreshToken(any),
        ).thenAnswer((_) async => Right(tokenResponse));

        final result = await mockRefreshDataSource.refreshToken('test-token');

        expect(result.isRight, isTrue);
        expect(result.right.accessToken, 'new-access-token');
        verify(mockRefreshDataSource.refreshToken('test-token')).called(1);
      });

      test('should properly mock failed token refresh', () async {
        final errorModel = ErrorModel(message: 'Session expired');

        when(
          mockRefreshDataSource.refreshToken(any),
        ).thenAnswer((_) async => Left(errorModel));

        final result = await mockRefreshDataSource.refreshToken('test-token');

        expect(result.isLeft, isTrue);
        expect(result.left.message, 'Session expired');
        verify(mockRefreshDataSource.refreshToken('test-token')).called(1);
      });
    });
  });
}

/// Mock handler for error interception
class _MockErrorInterceptorHandler extends ErrorInterceptorHandler {
  bool nextCalled = false;
  bool rejectCalled = false;
  bool resolveCalled = false;
  DioException? lastError;

  @override
  void next(DioException err) {
    nextCalled = true;
    lastError = err;
    // Don't call super to avoid actual error propagation in tests
  }

  @override
  void reject(DioException err) {
    rejectCalled = true;
    lastError = err;
  }

  @override
  void resolve(Response response) {
    resolveCalled = true;
  }
}
