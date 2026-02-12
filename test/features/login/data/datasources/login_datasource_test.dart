import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/user/data/datasources/user_session_data_source.dart';
import 'package:motogo_frontend/src/core/user/data/models/user_model.dart';
import 'package:motogo_frontend/src/features/login/data/datasources/login_data_source.dart';

import 'login_datasource_test.mocks.dart';

@GenerateMocks([UserSessionDataSource])
void main() {
  late LoginDataSource dataSource;
  late MockUserSessionDataSource mockUserSessionDataSource;
  late Dio mockDio;

  setUp(() {
    mockUserSessionDataSource = MockUserSessionDataSource();
    mockDio = Dio(BaseOptions(baseUrl: 'http://localhost'));
    dataSource = LoginDataSource(mockUserSessionDataSource, dio: mockDio);

    // Provide dummy for Either<ErrorModel, UserModel> so Mockito can handle unstubbed calls
    provideDummy<Either<ErrorModel, UserModel>>(
      Right(
        UserModel(
          id: '',
          identityNumber: '',
          firstName: '',
          lastName: '',
          email: '',
          phoneNumber: '',
          role: '',
        ),
      ),
    );
  });

  group('LoginDataSource', () {
    group('loginPerson', () {
      test('should return ErrorModel when success is false', () async {
        // Arrange
        mockDio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.resolve(
                Response(
                  requestOptions: options,
                  data: {
                    'success': false,
                    'code': 'ERR_AUTH_001',
                    'message': 'Credenciales incorrectas',
                  },
                  statusCode: 200,
                ),
              );
            },
          ),
        );

        // Act
        final result = await dataSource.loginPerson('user@test.com', 'wrong');

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel when data is null', () async {
        // Arrange
        mockDio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.resolve(
                Response(
                  requestOptions: options,
                  data: {
                    'success': true,
                    'message': 'Login exitoso',
                    'data': null,
                  },
                  statusCode: 200,
                ),
              );
            },
          ),
        );

        // Act
        final result = await dataSource.loginPerson('user@test.com', 'pass123');

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel when access_token is null', () async {
        // Arrange
        mockDio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.resolve(
                Response(
                  requestOptions: options,
                  data: {
                    'success': true,
                    'message': 'Login exitoso',
                    'data': {
                      'access_token': null,
                      'refresh_token': 'refresh-tok',
                    },
                  },
                  statusCode: 200,
                ),
              );
            },
          ),
        );

        // Act
        final result = await dataSource.loginPerson('user@test.com', 'pass123');

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel when profile fetch fails', () async {
        // Arrange
        mockDio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.resolve(
                Response(
                  requestOptions: options,
                  data: {
                    'success': true,
                    'message': 'Login exitoso',
                    'data': {
                      'access_token': 'valid-token',
                      'refresh_token': 'refresh-tok',
                    },
                  },
                  statusCode: 200,
                ),
              );
            },
          ),
        );

        when(
          mockUserSessionDataSource.fetchCurrentUser('valid-token'),
        ).thenAnswer(
          (_) async => Left(
            ErrorModel(
              message: 'Error fetching profile',
              errorCode: 'PROFILE_ERR',
            ),
          ),
        );

        // Act
        final result = await dataSource.loginPerson('user@test.com', 'pass123');

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left.message, 'Error fetching profile');
      });

      test(
        'should verify fetchCurrentUser is called with access token',
        () async {
          // Arrange
          mockDio.interceptors.add(
            InterceptorsWrapper(
              onRequest: (options, handler) {
                handler.resolve(
                  Response(
                    requestOptions: options,
                    data: {
                      'success': true,
                      'message': 'Login exitoso',
                      'data': {
                        'access_token': 'valid-token',
                        'refresh_token': 'refresh-tok',
                      },
                    },
                    statusCode: 200,
                  ),
                );
              },
            ),
          );

          when(
            mockUserSessionDataSource.fetchCurrentUser('valid-token'),
          ).thenAnswer(
            (_) async =>
                Left(ErrorModel(message: 'Profile error', errorCode: 'ERR')),
          );

          // Act
          await dataSource.loginPerson('user@test.com', 'pass123');

          // Assert - verify fetchCurrentUser was called with the right token
          verify(
            mockUserSessionDataSource.fetchCurrentUser('valid-token'),
          ).called(1);
        },
      );

      test('should return ErrorModel on DioException', () async {
        // Arrange
        mockDio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.reject(
                DioException(
                  type: DioExceptionType.connectionTimeout,
                  requestOptions: options,
                ),
              );
            },
          ),
        );

        // Act
        final result = await dataSource.loginPerson('user@test.com', 'pass123');

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });
    });
  });
}
