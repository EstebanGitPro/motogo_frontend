import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_messages.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/features/delete_motorcycle/data/datasources/delete_motorcycle_datasource.dart';

import 'delete_motorcycle_datasource_test.mocks.dart';

@GenerateMocks([DioClient])
void main() {
  late DeleteMotorcycleDataSourceImpl dataSource;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = DeleteMotorcycleDataSourceImpl(mockDioClient);
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

  group('DeleteMotorcycleDataSourceImpl', () {
    const testMotorcycleId = 'test-motorcycle-123';

    group('deleteMotorcycle', () {
      test('should return success message from backend on success', () async {
        // Arrange
        final responseData = {
          'success': true,
          'code': 'MOD_M_DEL_00001',
          'message': 'Motocicleta eliminada exitosamente',
        };

        when(
          mockDioClient.delete('/motorcycles/$testMotorcycleId'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.deleteMotorcycle(testMotorcycleId);

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, 'Motocicleta eliminada exitosamente');
        verify(
          mockDioClient.delete('/motorcycles/$testMotorcycleId'),
        ).called(1);
      });

      test(
        'should return fallback message when no message in response',
        () async {
          // Arrange
          final responseData = {'success': true, 'code': 'MOD_M_DEL_00001'};

          when(
            mockDioClient.delete('/motorcycles/$testMotorcycleId'),
          ).thenAnswer((_) async => createResponse(responseData));

          // Act
          final result = await dataSource.deleteMotorcycle(testMotorcycleId);

          // Assert
          expect(result.isRight, isTrue);
          expect(result.right, FallbackMessages.operationSuccess);
        },
      );

      test('should return ErrorModel when success is false', () async {
        // Arrange
        final responseData = {
          'success': false,
          'code': 'ERR_MOTORCYCLE_001',
          'message': 'No se puede eliminar la motocicleta, tiene historial',
        };

        when(
          mockDioClient.delete('/motorcycles/$testMotorcycleId'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.deleteMotorcycle(testMotorcycleId);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
        expect(
          result.left.message,
          'No se puede eliminar la motocicleta, tiene historial',
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
            mockDioClient.delete('/motorcycles/$testMotorcycleId'),
          ).thenAnswer((_) async => response);

          // Act
          final result = await dataSource.deleteMotorcycle(testMotorcycleId);

          // Assert
          expect(result.isRight, isTrue);
          expect(result.right, FallbackMessages.operationSuccess);
        },
      );

      test(
        'should return ErrorModel on DioException connectionTimeout',
        () async {
          // Arrange
          when(
            mockDioClient.delete('/motorcycles/$testMotorcycleId'),
          ).thenThrow(
            DioException(
              type: DioExceptionType.connectionTimeout,
              requestOptions: RequestOptions(
                path: '/motorcycles/$testMotorcycleId',
              ),
            ),
          );

          // Act
          final result = await dataSource.deleteMotorcycle(testMotorcycleId);

          // Assert
          expect(result.isLeft, isTrue);
          expect(result.left, isA<ErrorModel>());
        },
      );

      test(
        'should return ErrorModel on DioException badResponse 401',
        () async {
          // Arrange
          when(
            mockDioClient.delete('/motorcycles/$testMotorcycleId'),
          ).thenThrow(
            DioException(
              type: DioExceptionType.badResponse,
              requestOptions: RequestOptions(
                path: '/motorcycles/$testMotorcycleId',
              ),
              response: Response(
                requestOptions: RequestOptions(path: ''),
                statusCode: 401,
                data: {'message': 'Token expirado'},
              ),
            ),
          );

          // Act
          final result = await dataSource.deleteMotorcycle(testMotorcycleId);

          // Assert
          expect(result.isLeft, isTrue);
          expect(result.left, isA<ErrorModel>());
        },
      );

      test(
        'should return ErrorModel on DioException badResponse 500',
        () async {
          // Arrange
          when(
            mockDioClient.delete('/motorcycles/$testMotorcycleId'),
          ).thenThrow(
            DioException(
              type: DioExceptionType.badResponse,
              requestOptions: RequestOptions(
                path: '/motorcycles/$testMotorcycleId',
              ),
              response: Response(
                requestOptions: RequestOptions(path: ''),
                statusCode: 500,
                data: {'message': 'Internal server error'},
              ),
            ),
          );

          // Act
          final result = await dataSource.deleteMotorcycle(testMotorcycleId);

          // Assert
          expect(result.isLeft, isTrue);
        },
      );

      test('should return ErrorModel on generic exception', () async {
        // Arrange
        when(
          mockDioClient.delete('/motorcycles/$testMotorcycleId'),
        ).thenThrow(Exception('Network error'));

        // Act
        final result = await dataSource.deleteMotorcycle(testMotorcycleId);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should correctly append motorcycle ID to path', () async {
        // Arrange
        const specialId = 'special-motorcycle-uuid-456';
        final responseData = {'success': true, 'message': 'Deleted'};

        when(
          mockDioClient.delete('/motorcycles/$specialId'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        await dataSource.deleteMotorcycle(specialId);

        // Assert
        verify(mockDioClient.delete('/motorcycles/$specialId')).called(1);
      });
    });
  });
}
