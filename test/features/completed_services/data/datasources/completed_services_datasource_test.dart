import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/features/completed_services/data/datasources/completed_services_datasource.dart';
import 'package:motogo_frontend/src/features/completed_services/data/model/register_completed_service_model.dart';
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
    // ─── registerCompletedService ─────────────────────────────────

    group('registerCompletedService', () {
      const testRequest = RegisterCompletedServiceModel(
        branchId: 'branch-123',
        motorcycleId: 'moto-456',
        serviceIds: ['svc-1', 'svc-2'],
        quotedPrice: 185000,
        finalPrice: 175000,
        representativeNotes: 'Cambio de aceite',
      );

      test('should return success message on success', () async {
        final responseData = {
          'success': true,
          'message': 'Servicio registrado exitosamente',
        };

        when(
          mockDioClient.post('/completed-services', data: anyNamed('data')),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.registerCompletedService(testRequest);

        expect(result.isRight, isTrue);
        expect(result.right, 'Servicio registrado exitosamente');
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR_CS_001',
          'message': 'Error al registrar',
        };

        when(
          mockDioClient.post('/completed-services', data: anyNamed('data')),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.registerCompletedService(testRequest);

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.post('/completed-services', data: anyNamed('data')),
        ).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.registerCompletedService(testRequest);

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel on generic exception', () async {
        when(
          mockDioClient.post('/completed-services', data: anyNamed('data')),
        ).thenThrow(Exception('Network error'));

        final result = await dataSource.registerCompletedService(testRequest);

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });
    });

    // ─── getCompletedServicesByBranch ──────────────────────────────

    group('getCompletedServicesByBranch', () {
      const testBranchId = 'branch-123';

      test('should return list of models on success', () async {
        final responseData = {
          'success': true,
          'data': [
            {
              'id': 'svc-1',
              'branch_id': testBranchId,
              'motorcycle_id': 'moto-1',
              'status': 'FINALIZADO',
              'request_date': '2026-02-15T10:00:00Z',
              'services': [],
            },
          ],
        };

        when(
          mockDioClient.get('/branches/$testBranchId/completed-services'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getCompletedServicesByBranch(
          testBranchId,
        );

        expect(result.isRight, isTrue);
        expect(result.right, hasLength(1));
        expect(result.right[0].id, 'svc-1');
      });

      test('should return empty list when data is null', () async {
        final responseData = {'success': true};

        when(
          mockDioClient.get('/branches/$testBranchId/completed-services'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getCompletedServicesByBranch(
          testBranchId,
        );

        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Branch not found',
        };

        when(
          mockDioClient.get('/branches/$testBranchId/completed-services'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getCompletedServicesByBranch(
          testBranchId,
        );

        expect(result.isLeft, isTrue);
      });

      test('should return empty list when response is not Map', () async {
        when(
          mockDioClient.get('/branches/$testBranchId/completed-services'),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.getCompletedServicesByBranch(
          testBranchId,
        );

        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.get('/branches/$testBranchId/completed-services'),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.getCompletedServicesByBranch(
          testBranchId,
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on generic exception', () async {
        when(
          mockDioClient.get('/branches/$testBranchId/completed-services'),
        ).thenThrow(Exception('Network error'));

        final result = await dataSource.getCompletedServicesByBranch(
          testBranchId,
        );

        expect(result.isLeft, isTrue);
      });
    });

    // ─── getCompletedServicesByMotorcycle ──────────────────────────

    group('getCompletedServicesByMotorcycle', () {
      const testMotorcycleId = 'moto-456';

      test('should return list of models on success', () async {
        final responseData = {
          'success': true,
          'data': [
            {
              'id': 'svc-1',
              'branch_id': 'branch-1',
              'motorcycle_id': testMotorcycleId,
              'status': 'FINALIZADO',
              'request_date': '2026-02-15T10:00:00Z',
              'services': [],
            },
          ],
        };

        when(
          mockDioClient.get(
            '/motorcycles/$testMotorcycleId/completed-services',
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getCompletedServicesByMotorcycle(
          testMotorcycleId,
        );

        expect(result.isRight, isTrue);
        expect(result.right, hasLength(1));
      });

      test('should return empty list when data is null', () async {
        final responseData = {'success': true};

        when(
          mockDioClient.get(
            '/motorcycles/$testMotorcycleId/completed-services',
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getCompletedServicesByMotorcycle(
          testMotorcycleId,
        );

        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Not found',
        };

        when(
          mockDioClient.get(
            '/motorcycles/$testMotorcycleId/completed-services',
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getCompletedServicesByMotorcycle(
          testMotorcycleId,
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.get(
            '/motorcycles/$testMotorcycleId/completed-services',
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.getCompletedServicesByMotorcycle(
          testMotorcycleId,
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on generic exception', () async {
        when(
          mockDioClient.get(
            '/motorcycles/$testMotorcycleId/completed-services',
          ),
        ).thenThrow(Exception('Network error'));

        final result = await dataSource.getCompletedServicesByMotorcycle(
          testMotorcycleId,
        );

        expect(result.isLeft, isTrue);
      });
    });

    // ─── deleteCompletedService ────────────────────────────────────

    group('deleteCompletedService', () {
      const testServiceId = 'service-123';

      test('should return success message on success', () async {
        final responseData = {
          'success': true,
          'message': 'Servicio eliminado exitosamente',
        };

        when(
          mockDioClient.delete('/completed-services/$testServiceId'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.deleteCompletedService(testServiceId);

        expect(result.isRight, isTrue);
        expect(result.right, 'Servicio eliminado exitosamente');
      });

      test(
        'should return default message when no message in response',
        () async {
          final responseData = {'success': true};

          when(
            mockDioClient.delete('/completed-services/$testServiceId'),
          ).thenAnswer((_) async => createResponse(responseData));

          final result = await dataSource.deleteCompletedService(testServiceId);

          expect(result.isRight, isTrue);
          expect(result.right, 'Servicio eliminado exitosamente');
        },
      );

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'No se pudo eliminar',
        };

        when(
          mockDioClient.delete('/completed-services/$testServiceId'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.deleteCompletedService(testServiceId);

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.delete('/completed-services/$testServiceId'),
        ).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.deleteCompletedService(testServiceId);

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on generic exception', () async {
        when(
          mockDioClient.delete('/completed-services/$testServiceId'),
        ).thenThrow(Exception('Network error'));

        final result = await dataSource.deleteCompletedService(testServiceId);

        expect(result.isLeft, isTrue);
      });
    });

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
