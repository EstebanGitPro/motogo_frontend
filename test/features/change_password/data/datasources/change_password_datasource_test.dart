import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/errors/error_messages.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/change_password/data/datasources/change_password_data_source.dart';

void main() {
  late ChangePasswordDataSourceImpl dataSource;
  late Dio mockDio;

  setUp(() {
    mockDio = Dio(BaseOptions(baseUrl: 'http://localhost'));
    dataSource = ChangePasswordDataSourceImpl(dio: mockDio);
  });

  group('ChangePasswordDataSourceImpl', () {
    group('changePassword', () {
      test(
        'should return success message on successful password change',
        () async {
          // Arrange - use interceptor to mock the response
          mockDio.interceptors.add(
            InterceptorsWrapper(
              onRequest: (options, handler) {
                handler.resolve(
                  Response(
                    requestOptions: options,
                    data: {
                      'success': true,
                      'message': 'Contraseña cambiada exitosamente',
                    },
                    statusCode: 200,
                  ),
                );
              },
            ),
          );

          // Act
          final result = await dataSource.changePassword(
            currentPassword: 'oldPass123',
            newPassword: 'newPass456',
            token: 'test-token',
          );

          // Assert
          expect(result.isRight, isTrue);
          expect(result.right, 'Contraseña cambiada exitosamente');
        },
      );

      test(
        'should return fallback message when no message in response',
        () async {
          mockDio.interceptors.add(
            InterceptorsWrapper(
              onRequest: (options, handler) {
                handler.resolve(
                  Response(
                    requestOptions: options,
                    data: {'success': true},
                    statusCode: 200,
                  ),
                );
              },
            ),
          );

          final result = await dataSource.changePassword(
            currentPassword: 'oldPass123',
            newPassword: 'newPass456',
            token: 'test-token',
          );

          expect(result.isRight, isTrue);
          expect(result.right, FallbackMessages.operationSuccess);
        },
      );

      test('should return ErrorModel when success is false', () async {
        mockDio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.resolve(
                Response(
                  requestOptions: options,
                  data: {
                    'success': false,
                    'code': 'ERR_PWD_001',
                    'message': 'Contraseña actual incorrecta',
                  },
                  statusCode: 200,
                ),
              );
            },
          ),
        );

        final result = await dataSource.changePassword(
          currentPassword: 'wrongPass',
          newPassword: 'newPass456',
          token: 'test-token',
        );

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel on DioException', () async {
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

        final result = await dataSource.changePassword(
          currentPassword: 'oldPass123',
          newPassword: 'newPass456',
          token: 'test-token',
        );

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should include Authorization header with bearer token', () async {
        String? capturedAuth;
        mockDio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              capturedAuth = options.headers['Authorization'] as String?;
              handler.resolve(
                Response(
                  requestOptions: options,
                  data: {'success': true, 'message': 'OK'},
                  statusCode: 200,
                ),
              );
            },
          ),
        );

        await dataSource.changePassword(
          currentPassword: 'old',
          newPassword: 'new',
          token: 'my-jwt-token',
        );

        expect(capturedAuth, 'Bearer my-jwt-token');
      });
    });
  });
}
