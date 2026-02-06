import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_messages.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/features/delete_branch/data/datasources/delete_branch_data_source.dart';

import 'delete_branch_data_source_test.mocks.dart';

@GenerateMocks([DioClient])
void main() {
  late DeleteBranchDataSourceImpl dataSource;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = DeleteBranchDataSourceImpl(mockDioClient);
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

  group('DeleteBranchDataSourceImpl', () {
    const testBranchId = 'test-branch-123';

    group('deleteBranch', () {
      test('should return success message from backend on success', () async {
        // Arrange
        final responseData = {
          'success': true,
          'code': 'MOD_B_DEL_00001',
          'message': 'Sede eliminada exitosamente',
        };

        when(
          mockDioClient.delete('/branches/$testBranchId'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.deleteBranch(testBranchId);

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, 'Sede eliminada exitosamente');
        verify(mockDioClient.delete('/branches/$testBranchId')).called(1);
      });

      test(
        'should return fallback message when no message in response',
        () async {
          // Arrange
          final responseData = {'success': true, 'code': 'MOD_B_DEL_00001'};

          when(
            mockDioClient.delete('/branches/$testBranchId'),
          ).thenAnswer((_) async => createResponse(responseData));

          // Act
          final result = await dataSource.deleteBranch(testBranchId);

          // Assert
          expect(result.isRight, isTrue);
          expect(result.right, FallbackMessages.operationSuccess);
        },
      );

      test('should return ErrorModel when success is false', () async {
        // Arrange
        final responseData = {
          'success': false,
          'code': 'ERR_BRANCH_001',
          'message': 'No se puede eliminar la sede, tiene servicios activos',
        };

        when(
          mockDioClient.delete('/branches/$testBranchId'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.deleteBranch(testBranchId);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
        expect(
          result.left.message,
          'No se puede eliminar la sede, tiene servicios activos',
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
            mockDioClient.delete('/branches/$testBranchId'),
          ).thenAnswer((_) async => response);

          // Act
          final result = await dataSource.deleteBranch(testBranchId);

          // Assert
          expect(result.isRight, isTrue);
          expect(result.right, FallbackMessages.operationSuccess);
        },
      );

      test(
        'should return ErrorModel on DioException connectionTimeout',
        () async {
          // Arrange
          when(mockDioClient.delete('/branches/$testBranchId')).thenThrow(
            DioException(
              type: DioExceptionType.connectionTimeout,
              requestOptions: RequestOptions(path: '/branches/$testBranchId'),
            ),
          );

          // Act
          final result = await dataSource.deleteBranch(testBranchId);

          // Assert
          expect(result.isLeft, isTrue);
          expect(result.left, isA<ErrorModel>());
        },
      );

      test(
        'should return ErrorModel on DioException badResponse 401',
        () async {
          // Arrange
          when(mockDioClient.delete('/branches/$testBranchId')).thenThrow(
            DioException(
              type: DioExceptionType.badResponse,
              requestOptions: RequestOptions(path: '/branches/$testBranchId'),
              response: Response(
                requestOptions: RequestOptions(path: ''),
                statusCode: 401,
                data: {'message': 'Token expirado'},
              ),
            ),
          );

          // Act
          final result = await dataSource.deleteBranch(testBranchId);

          // Assert
          expect(result.isLeft, isTrue);
          expect(result.left, isA<ErrorModel>());
        },
      );

      test(
        'should return ErrorModel on DioException badResponse 500',
        () async {
          // Arrange
          when(mockDioClient.delete('/branches/$testBranchId')).thenThrow(
            DioException(
              type: DioExceptionType.badResponse,
              requestOptions: RequestOptions(path: '/branches/$testBranchId'),
              response: Response(
                requestOptions: RequestOptions(path: ''),
                statusCode: 500,
                data: {'message': 'Internal server error'},
              ),
            ),
          );

          // Act
          final result = await dataSource.deleteBranch(testBranchId);

          // Assert
          expect(result.isLeft, isTrue);
        },
      );

      test('should return ErrorModel on generic exception', () async {
        // Arrange
        when(
          mockDioClient.delete('/branches/$testBranchId'),
        ).thenThrow(Exception('Network error'));

        // Act
        final result = await dataSource.deleteBranch(testBranchId);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should correctly append branch ID to path', () async {
        // Arrange
        const specialId = 'special-branch-uuid-456';
        final responseData = {'success': true, 'message': 'Deleted'};

        when(
          mockDioClient.delete('/branches/$specialId'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        await dataSource.deleteBranch(specialId);

        // Assert
        verify(mockDioClient.delete('/branches/$specialId')).called(1);
      });
    });
  });
}
