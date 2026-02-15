import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/features/service_ratings/data/datasources/rating_range_datasource.dart';

import 'rating_range_datasource_test.mocks.dart';

@GenerateMocks([DioClient])
void main() {
  late RatingRangeDataSourceImpl dataSource;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = RatingRangeDataSourceImpl(mockDioClient);
  });

  Response<dynamic> createResponse(dynamic data, {int statusCode = 200}) {
    return Response(
      requestOptions: RequestOptions(path: ''),
      data: data,
      statusCode: statusCode,
    );
  }

  group('RatingRangeDataSourceImpl', () {
    group('getRatingRanges', () {
      test('should return list of rating ranges on success', () async {
        final responseData = {
          'success': true,
          'data': {
            'ratings': [
              {'value': 1, 'label': 'Muy malo'},
              {'value': 5, 'label': 'Excelente'},
            ],
          },
        };

        when(
          mockDioClient.get('/rating-ranges'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getRatingRanges();

        expect(result.isRight, isTrue);
        expect(result.right.length, 2);
        verify(mockDioClient.get('/rating-ranges')).called(1);
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR_RATING_001',
          'message': 'Error al obtener rangos',
        };

        when(
          mockDioClient.get('/rating-ranges'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getRatingRanges();

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return empty list when response is not a Map', () async {
        when(
          mockDioClient.get('/rating-ranges'),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.getRatingRanges();

        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return empty list when data is null', () async {
        final responseData = {'success': true, 'data': null};

        when(
          mockDioClient.get('/rating-ranges'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getRatingRanges();

        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return empty list when ratings is null', () async {
        final responseData = {'success': true, 'data': <String, dynamic>{}};

        when(
          mockDioClient.get('/rating-ranges'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getRatingRanges();

        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return ErrorModel on DioException', () async {
        when(mockDioClient.get('/rating-ranges')).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.getRatingRanges();

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel on generic exception', () async {
        when(
          mockDioClient.get('/rating-ranges'),
        ).thenThrow(Exception('Network error'));

        final result = await dataSource.getRatingRanges();

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });
    });
  });
}
