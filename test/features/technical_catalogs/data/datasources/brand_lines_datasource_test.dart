import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/data/datasources/brand_lines_datasource.dart';

import 'brand_lines_datasource_test.mocks.dart';

@GenerateMocks([DioClient])
void main() {
  late BrandLinesDataSourceImpl dataSource;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = BrandLinesDataSourceImpl(mockDioClient);
  });

  Response<dynamic> createResponse(dynamic data, {int statusCode = 200}) {
    return Response(
      requestOptions: RequestOptions(path: ''),
      data: data,
      statusCode: statusCode,
    );
  }

  group('BrandLinesDataSourceImpl', () {
    const testBrandId = 'brand-123';

    group('getBrandLines', () {
      test('should return list of brand lines on success', () async {
        // Arrange
        final responseData = {
          'success': true,
          'data': {
            'lines': [
              {'id': 'line-1', 'name': 'AKT NKD 125'},
              {'id': 'line-2', 'name': 'AKT TT 150'},
            ],
          },
        };

        when(
          mockDioClient.get('/admin/brands/$testBrandId/lines'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.getBrandLines(testBrandId);

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right.length, 2);
        verify(mockDioClient.get('/admin/brands/$testBrandId/lines')).called(1);
      });

      test('should return ErrorModel when success is false', () async {
        // Arrange
        final responseData = {
          'success': false,
          'code': 'ERR_BRAND_001',
          'message': 'Marca no encontrada',
        };

        when(
          mockDioClient.get('/admin/brands/$testBrandId/lines'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.getBrandLines(testBrandId);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return empty list when response is not a Map', () async {
        // Arrange
        when(
          mockDioClient.get('/admin/brands/$testBrandId/lines'),
        ).thenAnswer((_) async => createResponse('not a map'));

        // Act
        final result = await dataSource.getBrandLines(testBrandId);

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return ErrorModel on DioException', () async {
        // Arrange
        when(mockDioClient.get('/admin/brands/$testBrandId/lines')).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        // Act
        final result = await dataSource.getBrandLines(testBrandId);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel on generic exception', () async {
        // Arrange
        when(
          mockDioClient.get('/admin/brands/$testBrandId/lines'),
        ).thenThrow(Exception('Network error'));

        // Act
        final result = await dataSource.getBrandLines(testBrandId);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });
    });
  });
}
