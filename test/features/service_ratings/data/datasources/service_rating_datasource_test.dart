import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/features/service_ratings/data/datasources/service_rating_datasource.dart';
import 'package:motogo_frontend/src/features/service_ratings/data/models/rate_service_request.dart';

@GenerateMocks([DioClient])
import 'service_rating_datasource_test.mocks.dart';

void main() {
  late ServiceRatingDataSourceImpl dataSource;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = ServiceRatingDataSourceImpl(mockDioClient);
  });

  Response<dynamic> createResponse(dynamic data, {int statusCode = 200}) {
    return Response(
      requestOptions: RequestOptions(path: ''),
      data: data,
      statusCode: statusCode,
    );
  }

  group('ServiceRatingDataSourceImpl', () {
    group('rateServiceItem', () {
      const completedServiceId = 'cs-123';
      const itemId = 'item-456';
      const request = RateServiceRequest(rating: 5, comment: 'Excelente');
      final expectedPath =
          '/completed-services/$completedServiceId/items/$itemId/rating';

      test('should return success message on successful rating', () async {
        final responseData = {
          'success': true,
          'message': 'Calificación registrada',
        };

        when(
          mockDioClient.post(expectedPath, data: request.toJson()),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.rateServiceItem(
          completedServiceId,
          itemId,
          request,
        );

        expect(result.isRight, isTrue);
        expect(result.right, 'Calificación registrada');
        verify(
          mockDioClient.post(expectedPath, data: request.toJson()),
        ).called(1);
      });

      test(
        'should return default message when backend omits message',
        () async {
          final responseData = {'success': true};

          when(
            mockDioClient.post(expectedPath, data: request.toJson()),
          ).thenAnswer((_) async => createResponse(responseData));

          final result = await dataSource.rateServiceItem(
            completedServiceId,
            itemId,
            request,
          );

          expect(result.isRight, isTrue);
          expect(result.right, 'Calificación registrada exitosamente');
        },
      );

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR_RATING_001',
          'message': 'Servicio ya calificado',
        };

        when(
          mockDioClient.post(expectedPath, data: request.toJson()),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.rateServiceItem(
          completedServiceId,
          itemId,
          request,
        );

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test(
        'should return default message when response is not a Map',
        () async {
          when(
            mockDioClient.post(expectedPath, data: request.toJson()),
          ).thenAnswer((_) async => createResponse('not a map'));

          final result = await dataSource.rateServiceItem(
            completedServiceId,
            itemId,
            request,
          );

          expect(result.isRight, isTrue);
          expect(result.right, 'Calificación registrada exitosamente');
        },
      );

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.post(expectedPath, data: request.toJson()),
        ).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.rateServiceItem(
          completedServiceId,
          itemId,
          request,
        );

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel on generic exception', () async {
        when(
          mockDioClient.post(expectedPath, data: request.toJson()),
        ).thenThrow(Exception('Network error'));

        final result = await dataSource.rateServiceItem(
          completedServiceId,
          itemId,
          request,
        );

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });
    });

    group('getServiceReviews', () {
      const serviceId = 'svc-789';

      test('should return ServiceReviewSummaryEntity on success', () async {
        final responseData = {
          'success': true,
          'data': {
            'service_id': serviceId,
            'service_name': 'Cambio de aceite',
            'average_rating': 4.5,
            'total_reviews': 10,
            'breakdown': {'5': 5, '4': 3, '3': 1, '2': 1, '1': 0},
            'reviews': [
              {
                'reviewer_name': 'Carlos Martinez',
                'rating': 5,
                'comment': 'Excelente',
                'rated_at': '2025-01-15T10:00:00Z',
                'motorcycle_model': 'Yamaha MT-07',
              },
            ],
          },
        };

        when(
          mockDioClient.get('/services/$serviceId/reviews'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getServiceReviews(serviceId);

        expect(result.isRight, isTrue);
        expect(result.right.serviceId, serviceId);
        expect(result.right.averageRating, 4.5);
        expect(result.right.reviews.length, 1);
        verify(mockDioClient.get('/services/$serviceId/reviews')).called(1);
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR_001',
          'message': 'Servicio no encontrado',
        };

        when(
          mockDioClient.get('/services/$serviceId/reviews'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getServiceReviews(serviceId);

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel on DioException', () async {
        when(mockDioClient.get('/services/$serviceId/reviews')).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.getServiceReviews(serviceId);

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel on generic exception', () async {
        when(
          mockDioClient.get('/services/$serviceId/reviews'),
        ).thenThrow(Exception('Network error'));

        final result = await dataSource.getServiceReviews(serviceId);

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });
    });
  });
}
