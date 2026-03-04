import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/auth_interceptor.dart';
import 'package:motogo_frontend/src/core/network/refresh_token_data_source.dart';
import 'package:motogo_frontend/src/core/network/token_response.dart';
import 'package:motogo_frontend/src/core/user/domain/entities/user_entity.dart';
import 'package:motogo_frontend/src/core/user/user_session_manager.dart';

import 'auth_interceptor_test.mocks.dart';

const _testUser = UserEntity(
  id: 'test-user',
  identityNumber: '1234567890',
  firstName: 'Test',
  lastName: 'User',
  email: 'test@test.com',
  phoneNumber: '3001234567',
  role: 'User',
);

@GenerateMocks([RefreshTokenDataSource, FlutterSecureStorage])
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
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockRefreshDataSource = MockRefreshTokenDataSource();
    interceptor = AuthInterceptor(mockRefreshDataSource);

    // Mock FlutterSecureStorage to avoid MissingPluginException
    mockStorage = MockFlutterSecureStorage();
    UserSessionManager.instance.resetForTesting();
    UserSessionManager.instance.secureStorageOverride = mockStorage;

    // Default stubs for storage operations
    when(
      mockStorage.write(key: anyNamed('key'), value: anyNamed('value')),
    ).thenAnswer((_) async {});
    when(mockStorage.delete(key: anyNamed('key'))).thenAnswer((_) async {});
    when(mockStorage.read(key: anyNamed('key'))).thenAnswer((_) async => null);
  });

  tearDown(() {
    UserSessionManager.instance.resetForTesting();
  });

  group('AuthInterceptor', () {
    group('constructor', () {
      test('should create with RefreshTokenDataSource', () {
        expect(interceptor, isA<AuthInterceptor>());
        expect(interceptor, isA<Interceptor>());
      });
    });

    group('onRequest', () {
      test('should call handler.next to continue the chain', () async {
        final options = RequestOptions(path: '/test');
        final handler = _MockRequestInterceptorHandler();

        interceptor.onRequest(options, handler);

        // Give time for async getAccessToken()
        await Future.delayed(const Duration(milliseconds: 100));
        expect(handler.nextCalled, isTrue);
      });

      test('should forward request options through the chain', () async {
        final options = RequestOptions(
          path: '/branches',
          method: 'GET',
          headers: {'Content-Type': 'application/json'},
        );
        final handler = _MockRequestInterceptorHandler();

        interceptor.onRequest(options, handler);

        await Future.delayed(const Duration(milliseconds: 100));
        expect(handler.nextCalled, isTrue);
        expect(handler.lastOptions?.path, '/branches');
      });

      test('should add Authorization header when token is available', () async {
        // Save a session with a known token
        await UserSessionManager.instance.saveSession(
          accessToken: 'test-token-123',
          refreshToken: 'refresh-123',
          user: _testUser,
        );

        final options = RequestOptions(path: '/motorcycles');
        final handler = _MockRequestInterceptorHandler();

        interceptor.onRequest(options, handler);

        await Future.delayed(const Duration(milliseconds: 100));
        expect(handler.nextCalled, isTrue);
        expect(
          handler.lastOptions?.headers['Authorization'],
          'Bearer test-token-123',
        );
      });

      test('should not add Authorization header when no token', () async {
        final options = RequestOptions(path: '/test');
        final handler = _MockRequestInterceptorHandler();

        interceptor.onRequest(options, handler);

        await Future.delayed(const Duration(milliseconds: 100));
        expect(handler.nextCalled, isTrue);
        expect(handler.lastOptions?.headers['Authorization'], isNull);
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

      test('should pass through errors without response (e.g. timeout)', () {
        final options = RequestOptions(path: '/test');
        final error = DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
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

    group('onError - 401 with token refresh (no refresh token)', () {
      test('should call next when no refresh token is available', () async {
        // No session saved = no refresh token
        final options = RequestOptions(path: '/branches');
        final response = Response(requestOptions: options, statusCode: 401);
        final error = DioException(
          requestOptions: options,
          response: response,
          type: DioExceptionType.badResponse,
        );
        final handler = _MockErrorInterceptorHandler();

        interceptor.onError(error, handler);

        await Future.delayed(const Duration(milliseconds: 300));

        expect(handler.nextCalled, isTrue);
      });
    });

    group('onError - 401 with refresh token available', () {
      test('should attempt refresh and call next on refresh failure', () async {
        // Save session with refresh token
        await UserSessionManager.instance.saveSession(
          accessToken: 'old-access',
          refreshToken: 'old-refresh',
          user: _testUser,
        );

        // Mock refresh to fail
        when(
          mockRefreshDataSource.refreshToken('old-refresh'),
        ).thenAnswer((_) async => Left(ErrorModel(message: 'Refresh failed')));

        final options = RequestOptions(path: '/motorcycles');
        final response = Response(requestOptions: options, statusCode: 401);
        final error = DioException(
          requestOptions: options,
          response: response,
          type: DioExceptionType.badResponse,
        );
        final handler = _MockErrorInterceptorHandler();

        interceptor.onError(error, handler);

        await Future.delayed(const Duration(milliseconds: 500));

        verify(mockRefreshDataSource.refreshToken('old-refresh')).called(1);
        expect(handler.nextCalled, isTrue);
      });

      test('should clear session when refresh fails', () async {
        await UserSessionManager.instance.saveSession(
          accessToken: 'old-access',
          refreshToken: 'old-refresh',
          user: _testUser,
        );

        when(
          mockRefreshDataSource.refreshToken('old-refresh'),
        ).thenAnswer((_) async => Left(ErrorModel(message: 'Token expired')));

        final options = RequestOptions(path: '/branches');
        final response = Response(requestOptions: options, statusCode: 401);
        final error = DioException(
          requestOptions: options,
          response: response,
          type: DioExceptionType.badResponse,
        );
        final handler = _MockErrorInterceptorHandler();

        interceptor.onError(error, handler);

        await Future.delayed(const Duration(milliseconds: 500));

        // Session should be cleared
        expect(UserSessionManager.instance.isAuthenticated, isFalse);
      });

      test('should attempt retry on successful refresh', () async {
        await UserSessionManager.instance.saveSession(
          accessToken: 'old-access',
          refreshToken: 'old-refresh',
          user: _testUser,
        );

        final tokenResponse = TokenResponse(
          accessToken: 'new-access-token',
          refreshToken: 'new-refresh-token',
          expiresIn: 3600,
          tokenType: 'Bearer',
        );

        when(
          mockRefreshDataSource.refreshToken('old-refresh'),
        ).thenAnswer((_) async => Right(tokenResponse));

        final options = RequestOptions(
          path: '/branches',
          baseUrl: 'http://localhost:8085/motogo/api/v1',
        );
        final response = Response(requestOptions: options, statusCode: 401);
        final error = DioException(
          requestOptions: options,
          response: response,
          type: DioExceptionType.badResponse,
        );
        final handler = _MockErrorInterceptorHandler();

        interceptor.onError(error, handler);

        await Future.delayed(const Duration(milliseconds: 500));

        // Token should be updated in session
        expect(UserSessionManager.instance.accessToken, 'new-access-token');
        verify(mockRefreshDataSource.refreshToken('old-refresh')).called(1);
        // handler.next should be called (retry will fail because no server,
        // but the refresh logic itself was exercised)
        expect(handler.nextCalled, isTrue);
      });
    });

    group('onError - refresh exception handling', () {
      test('should handle exception during refresh gracefully', () async {
        await UserSessionManager.instance.saveSession(
          accessToken: 'token',
          refreshToken: 'refresh',
          user: _testUser,
        );

        when(
          mockRefreshDataSource.refreshToken('refresh'),
        ).thenThrow(Exception('Network error during refresh'));

        final options = RequestOptions(path: '/admin/users');
        final response = Response(requestOptions: options, statusCode: 401);
        final error = DioException(
          requestOptions: options,
          response: response,
          type: DioExceptionType.badResponse,
        );
        final handler = _MockErrorInterceptorHandler();

        interceptor.onError(error, handler);

        await Future.delayed(const Duration(milliseconds: 500));

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

    group('TokenResponse', () {
      test('should parse from JSON correctly', () {
        final json = {
          'access_token': 'at-123',
          'refresh_token': 'rt-456',
          'expires_in': 1800,
          'token_type': 'Bearer',
        };

        final response = TokenResponse.fromJson(json);

        expect(response.accessToken, 'at-123');
        expect(response.refreshToken, 'rt-456');
        expect(response.expiresIn, 1800);
        expect(response.tokenType, 'Bearer');
      });

      test('should use defaults for optional fields', () {
        final json = {'access_token': 'at-123', 'refresh_token': 'rt-456'};

        final response = TokenResponse.fromJson(json);

        expect(response.expiresIn, 300); // default
        expect(response.tokenType, 'Bearer'); // default
      });
    });
  });
}

/// Mock handler for request interception
class _MockRequestInterceptorHandler extends RequestInterceptorHandler {
  bool nextCalled = false;
  RequestOptions? lastOptions;

  @override
  void next(RequestOptions requestOptions) {
    nextCalled = true;
    lastOptions = requestOptions;
  }
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
