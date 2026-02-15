import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/data/datasources/category_lines_datasource.dart';

import 'category_lines_datasource_test.mocks.dart';

@GenerateMocks([DioClient])
void main() {
  late CategoryLinesDataSourceImpl dataSource;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = CategoryLinesDataSourceImpl(mockDioClient);
  });

  Response<dynamic> createResponse(dynamic data, {int statusCode = 200}) {
    return Response(
      requestOptions: RequestOptions(path: ''),
      data: data,
      statusCode: statusCode,
    );
  }

  group('CategoryLinesDataSourceImpl', () {
    group('getCategories', () {
      test('should return list of categories on success', () async {
        final responseData = {
          'success': true,
          'data': {
            'categories': [
              {'name': 'Sport', 'display_name': 'Deportiva'},
              {'name': 'Scooter', 'display_name': 'Scooter'},
            ],
          },
        };

        when(
          mockDioClient.get('/motorcycle-categories'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getCategories();

        expect(result.isRight, isTrue);
        expect(result.right.length, 2);
        verify(mockDioClient.get('/motorcycle-categories')).called(1);
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR_CAT_001',
          'message': 'Error al obtener categorías',
        };

        when(
          mockDioClient.get('/motorcycle-categories'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getCategories();

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return empty list when response is not a Map', () async {
        when(
          mockDioClient.get('/motorcycle-categories'),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.getCategories();

        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return ErrorModel on DioException', () async {
        when(mockDioClient.get('/motorcycle-categories')).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.getCategories();

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel on generic exception', () async {
        when(
          mockDioClient.get('/motorcycle-categories'),
        ).thenThrow(Exception('Network error'));

        final result = await dataSource.getCategories();

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });
    });

    group('getCategoryLines', () {
      const testCategory = 'Sport';

      test('should return list of lines on success', () async {
        final responseData = {
          'success': true,
          'data': {
            'lines': [
              {
                'id': 'line-1',
                'name': 'CBR',
                'category': 'Sport',
                'brand_name': 'Honda',
              },
            ],
          },
        };

        when(
          mockDioClient.get('/motorcycle-categories/$testCategory/lines'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getCategoryLines(testCategory);

        expect(result.isRight, isTrue);
        expect(result.right.length, 1);
        verify(
          mockDioClient.get('/motorcycle-categories/$testCategory/lines'),
        ).called(1);
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR_LINE_001',
          'message': 'Error al obtener líneas',
        };

        when(
          mockDioClient.get('/motorcycle-categories/$testCategory/lines'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getCategoryLines(testCategory);

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return empty list when response is not a Map', () async {
        when(
          mockDioClient.get('/motorcycle-categories/$testCategory/lines'),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.getCategoryLines(testCategory);

        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.get('/motorcycle-categories/$testCategory/lines'),
        ).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.getCategoryLines(testCategory);

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel on generic exception', () async {
        when(
          mockDioClient.get('/motorcycle-categories/$testCategory/lines'),
        ).thenThrow(Exception('Network error'));

        final result = await dataSource.getCategoryLines(testCategory);

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });
    });
  });
}
