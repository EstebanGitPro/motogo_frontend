import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/constants/person_constants.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/features/delete_person/data/datasources/delete_person_data_source.dart';

import 'delete_person_data_source_test.mocks.dart';

@GenerateMocks([DioClient])
void main() {
  late DeletePersonDataSourceImpl dataSource;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = DeletePersonDataSourceImpl(mockDioClient);
  });

  // Helper to create Dio Response
  Response<dynamic> createResponse(
    Map<String, dynamic> data, {
    int statusCode = 200,
  }) {
    return Response(
      requestOptions: RequestOptions(path: ''),
      data: data,
      statusCode: statusCode,
    );
  }

  group('DeletePersonDataSourceImpl', () {
    group('deleteAccount', () {
      test('should return success message from backend on success', () async {
        // Arrange
        final responseData = {
          'success': true,
          'code': 'MOD_P_USR_DEL_00001',
          'message': 'Usuario eliminado exitosamente',
        };

        when(
          mockDioClient.delete('/persons/me'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.deleteAccount();

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, 'Usuario eliminado exitosamente');
        verify(mockDioClient.delete('/persons/me')).called(1);
      });

      test(
        'should return fallback message when no message in response',
        () async {
          // Arrange
          final responseData = {'success': true, 'code': 'MOD_P_USR_DEL_00001'};

          when(
            mockDioClient.delete('/persons/me'),
          ).thenAnswer((_) async => createResponse(responseData));

          // Act
          final result = await dataSource.deleteAccount();

          // Assert
          expect(result.isRight, isTrue);
          expect(result.right, PersonConstants.deleteAccountFallbackSuccess);
        },
      );

      test('should return ErrorModel when success is false', () async {
        // Arrange
        final responseData = {
          'success': false,
          'code': 'ERR_PERSON_001',
          'message': 'No se puede eliminar la cuenta, tienes sedes activas',
        };

        when(
          mockDioClient.delete('/persons/me'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.deleteAccount();

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
        expect(
          result.left.message,
          'No se puede eliminar la cuenta, tienes sedes activas',
        );
      });

      test(
        'should return fallback message when response is not a Map',
        () async {
          // Arrange
          final response = Response(
            requestOptions: RequestOptions(path: ''),
            data: 'not a map',
            statusCode: 200,
          );

          when(
            mockDioClient.delete('/persons/me'),
          ).thenAnswer((_) async => response);

          // Act
          final result = await dataSource.deleteAccount();

          // Assert
          expect(result.isRight, isTrue);
          expect(result.right, PersonConstants.deleteAccountFallbackSuccess);
        },
      );

      test(
        'should return ErrorModel on DioException connectionTimeout',
        () async {
          // Arrange
          when(mockDioClient.delete('/persons/me')).thenThrow(
            DioException(
              type: DioExceptionType.connectionTimeout,
              requestOptions: RequestOptions(path: '/persons/me'),
            ),
          );

          // Act
          final result = await dataSource.deleteAccount();

          // Assert
          expect(result.isLeft, isTrue);
          expect(result.left, isA<ErrorModel>());
        },
      );

      test(
        'should return ErrorModel on DioException badResponse 401',
        () async {
          // Arrange
          when(mockDioClient.delete('/persons/me')).thenThrow(
            DioException(
              type: DioExceptionType.badResponse,
              requestOptions: RequestOptions(path: '/persons/me'),
              response: Response(
                requestOptions: RequestOptions(path: ''),
                statusCode: 401,
                data: {'message': 'Token expirado'},
              ),
            ),
          );

          // Act
          final result = await dataSource.deleteAccount();

          // Assert
          expect(result.isLeft, isTrue);
          expect(result.left, isA<ErrorModel>());
        },
      );

      test(
        'should return ErrorModel on DioException badResponse 500',
        () async {
          // Arrange
          when(mockDioClient.delete('/persons/me')).thenThrow(
            DioException(
              type: DioExceptionType.badResponse,
              requestOptions: RequestOptions(path: '/persons/me'),
              response: Response(
                requestOptions: RequestOptions(path: ''),
                statusCode: 500,
                data: {'message': 'Internal server error'},
              ),
            ),
          );

          // Act
          final result = await dataSource.deleteAccount();

          // Assert
          expect(result.isLeft, isTrue);
        },
      );

      test('should return ErrorModel on generic exception', () async {
        // Arrange
        when(
          mockDioClient.delete('/persons/me'),
        ).thenThrow(Exception('Network error'));

        // Act
        final result = await dataSource.deleteAccount();

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });
    });
  });
}
