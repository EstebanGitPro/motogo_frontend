import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/features/completed_services/data/datasources/completed_services_datasource.dart';
import 'package:motogo_frontend/src/features/completed_services/data/model/status_transition_model.dart';

import 'completed_services_datasource_test.mocks.dart';

@GenerateMocks([DioClient])
void main() {
  late CompletedServicesDataSourceImpl dataSource;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = CompletedServicesDataSourceImpl(mockDioClient);
  });

  Response<dynamic> createResponse(dynamic data, {int statusCode = 200}) {
    return Response(
      requestOptions: RequestOptions(path: ''),
      data: data,
      statusCode: statusCode,
    );
  }

  group('CompletedServicesDataSourceImpl', () {
    // ─── updateServiceStatus ───────────────────────────────────────

    group('updateServiceStatus', () {
      const testServiceId = 'service-123';
      const testNewStatus = 'EN_PROCESO';

      test('should return success message on success', () async {
        final responseData = {
          'success': true,
          'message': 'Estado actualizado exitosamente',
        };

        when(
          mockDioClient.patch(
            '/completed-services/$testServiceId/status',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.updateServiceStatus(
          testServiceId,
          testNewStatus,
        );

        expect(result.isRight, isTrue);
        expect(result.right, 'Estado actualizado exitosamente');
        verify(
          mockDioClient.patch(
            '/completed-services/$testServiceId/status',
            data: {'status': testNewStatus},
          ),
        ).called(1);
      });

      test(
        'should return default message when no message in response',
        () async {
          final responseData = {'success': true};

          when(
            mockDioClient.patch(
              '/completed-services/$testServiceId/status',
              data: anyNamed('data'),
            ),
          ).thenAnswer((_) async => createResponse(responseData));

          final result = await dataSource.updateServiceStatus(
            testServiceId,
            testNewStatus,
          );

          expect(result.isRight, isTrue);
          expect(result.right, 'Estado actualizado exitosamente');
        },
      );

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR_CS_001',
          'message': 'Transición de estado no permitida',
        };

        when(
          mockDioClient.patch(
            '/completed-services/$testServiceId/status',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.updateServiceStatus(
          testServiceId,
          testNewStatus,
        );

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return default message when response is not Map', () async {
        when(
          mockDioClient.patch(
            '/completed-services/$testServiceId/status',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.updateServiceStatus(
          testServiceId,
          testNewStatus,
        );

        expect(result.isRight, isTrue);
        expect(result.right, 'Estado actualizado exitosamente');
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.patch(
            '/completed-services/$testServiceId/status',
            data: anyNamed('data'),
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.updateServiceStatus(
          testServiceId,
          testNewStatus,
        );

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel on generic exception', () async {
        when(
          mockDioClient.patch(
            '/completed-services/$testServiceId/status',
            data: anyNamed('data'),
          ),
        ).thenThrow(Exception('Network error'));

        final result = await dataSource.updateServiceStatus(
          testServiceId,
          testNewStatus,
        );

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });
    });

    // ─── getServiceTransitions ─────────────────────────────────────

    group('getServiceTransitions', () {
      const testServiceId = 'service-123';

      test('should return list of transitions on success', () async {
        final responseData = {
          'success': true,
          'data': [
            {
              'id': 'trans-1',
              'previous_status': null,
              'new_status': 'PENDIENTE',
              'created_by': 'person-1',
              'created_at': '2026-02-16T10:00:00Z',
            },
            {
              'id': 'trans-2',
              'previous_status': 'PENDIENTE',
              'new_status': 'EN_PROCESO',
              'created_by': 'person-1',
              'created_at': '2026-02-16T11:00:00Z',
            },
          ],
        };

        when(
          mockDioClient.get('/completed-services/$testServiceId/transitions'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getServiceTransitions(testServiceId);

        expect(result.isRight, isTrue);
        expect(result.right, hasLength(2));
        expect(result.right[0], isA<StatusTransitionModel>());
        expect(result.right[0].newStatus, 'PENDIENTE');
        expect(result.right[0].previousStatus, isNull);
        expect(result.right[1].previousStatus, 'PENDIENTE');
        expect(result.right[1].newStatus, 'EN_PROCESO');
        verify(
          mockDioClient.get('/completed-services/$testServiceId/transitions'),
        ).called(1);
      });

      test('should return empty list when data is null', () async {
        final responseData = {'success': true};

        when(
          mockDioClient.get('/completed-services/$testServiceId/transitions'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getServiceTransitions(testServiceId);

        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR_CS_002',
          'message': 'Servicio no encontrado',
        };

        when(
          mockDioClient.get('/completed-services/$testServiceId/transitions'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getServiceTransitions(testServiceId);

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return empty list when response is not Map', () async {
        when(
          mockDioClient.get('/completed-services/$testServiceId/transitions'),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.getServiceTransitions(testServiceId);

        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.get('/completed-services/$testServiceId/transitions'),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 404,
            ),
          ),
        );

        final result = await dataSource.getServiceTransitions(testServiceId);

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel on generic exception', () async {
        when(
          mockDioClient.get('/completed-services/$testServiceId/transitions'),
        ).thenThrow(Exception('Network error'));

        final result = await dataSource.getServiceTransitions(testServiceId);

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });
    });
  });
}
