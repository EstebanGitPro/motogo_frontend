import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/features/admin_services/data/datasources/admin_service_datasource.dart';
import 'package:motogo_frontend/src/features/admin_services/data/models/admin_service_model.dart';

import 'admin_service_datasource_test.mocks.dart';

@GenerateMocks([DioClient])
void main() {
  late AdminServiceDataSourceImpl dataSource;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = AdminServiceDataSourceImpl(mockDioClient);
  });

  // Helper to create Dio Response
  Response<dynamic> createResponse(dynamic data, {int statusCode = 200}) {
    return Response(
      requestOptions: RequestOptions(path: ''),
      data: data,
      statusCode: statusCode,
    );
  }

  group('AdminServiceDataSourceImpl', () {
    group('getServices', () {
      test('should return list of services on success', () async {
        // Arrange
        final responseData = {
          'success': true,
          'data': {
            'services': [
              {
                'id': 'service-1',
                'name': 'Cambio de aceite',
                'description': 'Cambio de aceite de motor',
                'service_type': 'Mantenimiento',
                'is_active': true,
              },
              {
                'id': 'service-2',
                'name': 'Alineación',
                'description': 'Alineación de ruedas',
                'service_type': 'Reparación',
                'is_active': false,
              },
            ],
          },
        };

        when(
          mockDioClient.get('/services'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.getServices();

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right.length, 2);
        expect(result.right[0].id, 'service-1');
        expect(result.right[0].name, 'Cambio de aceite');
        expect(result.right[0].isActive, true);
        expect(result.right[1].id, 'service-2');
        expect(result.right[1].isActive, false);
        verify(mockDioClient.get('/services')).called(1);
      });

      test('should return empty list when services is null', () async {
        // Arrange
        final responseData = {
          'success': true,
          'data': {'services': null},
        };

        when(
          mockDioClient.get('/services'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.getServices();

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return empty list when data is null', () async {
        // Arrange
        final responseData = {'success': true, 'data': null};

        when(
          mockDioClient.get('/services'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.getServices();

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return ErrorModel when success is false', () async {
        // Arrange
        final responseData = {
          'success': false,
          'code': 'ERR_SERVICE_001',
          'message': 'Error al obtener servicios',
        };

        when(
          mockDioClient.get('/services'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.getServices();

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return empty list when response is not a Map', () async {
        // Arrange
        when(
          mockDioClient.get('/services'),
        ).thenAnswer((_) async => createResponse('not a map'));

        // Act
        final result = await dataSource.getServices();

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return ErrorModel on DioException', () async {
        // Arrange
        when(mockDioClient.get('/services')).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: '/services'),
          ),
        );

        // Act
        final result = await dataSource.getServices();

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel on generic exception', () async {
        // Arrange
        when(
          mockDioClient.get('/services'),
        ).thenThrow(Exception('Network error'));

        // Act
        final result = await dataSource.getServices();

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });
    });

    group('updateService', () {
      test('should return updated service on success', () async {
        // Arrange
        final responseData = {
          'success': true,
          'data': {
            'id': 'service-123',
            'name': 'Cambio de aceite actualizado',
            'description': 'Nueva descripción',
            'service_type': 'Mantenimiento',
            'is_active': true,
          },
        };

        when(
          mockDioClient.put(
            '/admin/services/service-123',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.updateService(
          serviceId: 'service-123',
          name: 'Cambio de aceite actualizado',
          serviceType: 'Mantenimiento',
          description: 'Nueva descripción',
          isActive: true,
        );

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, isA<AdminServiceModel>());
        expect(result.right.name, 'Cambio de aceite actualizado');
      });

      test('should include description in request when provided', () async {
        // Arrange
        final responseData = {
          'success': true,
          'data': {
            'id': 'service-123',
            'name': 'Test',
            'service_type': 'Type',
            'is_active': true,
          },
        };

        when(
          mockDioClient.put(
            '/admin/services/service-123',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        await dataSource.updateService(
          serviceId: 'service-123',
          name: 'Test',
          serviceType: 'Type',
          description: 'Descripción',
          isActive: true,
        );

        // Assert
        verify(
          mockDioClient.put(
            '/admin/services/service-123',
            data: {
              'name': 'Test',
              'service_type': 'Type',
              'description': 'Descripción',
              'is_active': true,
            },
          ),
        ).called(1);
      });

      test('should not include description when empty', () async {
        // Arrange
        final responseData = {
          'success': true,
          'data': {
            'id': 'service-123',
            'name': 'Test',
            'service_type': 'Type',
            'is_active': true,
          },
        };

        when(
          mockDioClient.put(
            '/admin/services/service-123',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        await dataSource.updateService(
          serviceId: 'service-123',
          name: 'Test',
          serviceType: 'Type',
          description: '',
        );

        // Assert
        verify(
          mockDioClient.put(
            '/admin/services/service-123',
            data: {'name': 'Test', 'service_type': 'Type'},
          ),
        ).called(1);
      });

      test('should return fallback model when data is null', () async {
        // Arrange
        final responseData = {'success': true, 'data': null};

        when(
          mockDioClient.put(
            '/admin/services/service-123',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.updateService(
          serviceId: 'service-123',
          name: 'Test',
          serviceType: 'Type',
          isActive: true,
        );

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right.id, 'service-123');
        expect(result.right.name, 'Test');
      });

      test('should return ErrorModel when success is false', () async {
        // Arrange
        final responseData = {
          'success': false,
          'code': 'ERR_SERVICE_404',
          'message': 'Servicio no encontrado',
        };

        when(
          mockDioClient.put(
            '/admin/services/service-123',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.updateService(
          serviceId: 'service-123',
          name: 'Test',
          serviceType: 'Type',
        );

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return fallback model when response is not Map', () async {
        // Arrange
        when(
          mockDioClient.put(
            '/admin/services/service-123',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse('not a map'));

        // Act
        final result = await dataSource.updateService(
          serviceId: 'service-123',
          name: 'Test',
          serviceType: 'Type',
        );

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right.id, 'service-123');
        expect(result.right.name, 'Test');
      });

      test('should return ErrorModel on DioException', () async {
        // Arrange
        when(
          mockDioClient.put(
            '/admin/services/service-123',
            data: anyNamed('data'),
          ),
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

        // Act
        final result = await dataSource.updateService(
          serviceId: 'service-123',
          name: 'Test',
          serviceType: 'Type',
        );

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });
    });

    group('activateService', () {
      test('should return success message on activation', () async {
        // Arrange
        final responseData = {
          'success': true,
          'message': 'Servicio activado exitosamente',
        };

        when(
          mockDioClient.patch('/admin/services/service-123/activate'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.activateService('service-123');

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, 'Servicio activado exitosamente');
        verify(
          mockDioClient.patch('/admin/services/service-123/activate'),
        ).called(1);
      });

      test(
        'should return default message when no message in response',
        () async {
          // Arrange
          final responseData = {'success': true};

          when(
            mockDioClient.patch('/admin/services/service-123/activate'),
          ).thenAnswer((_) async => createResponse(responseData));

          // Act
          final result = await dataSource.activateService('service-123');

          // Assert
          expect(result.isRight, isTrue);
          expect(result.right, 'Servicio activado');
        },
      );

      test('should return default message when response is not Map', () async {
        // Arrange
        when(
          mockDioClient.patch('/admin/services/service-123/activate'),
        ).thenAnswer((_) async => createResponse('not a map'));

        // Act
        final result = await dataSource.activateService('service-123');

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, 'Servicio activado');
      });

      test('should return ErrorModel when success is false', () async {
        // Arrange
        final responseData = {
          'success': false,
          'code': 'ERR_ACTIVATION',
          'message': 'No se pudo activar el servicio',
        };

        when(
          mockDioClient.patch('/admin/services/service-123/activate'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.activateService('service-123');

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel on DioException', () async {
        // Arrange
        when(
          mockDioClient.patch('/admin/services/service-123/activate'),
        ).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        // Act
        final result = await dataSource.activateService('service-123');

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });
    });

    group('deactivateService', () {
      test('should return success message on deactivation', () async {
        // Arrange
        final responseData = {
          'success': true,
          'message': 'Servicio desactivado exitosamente',
        };

        when(
          mockDioClient.patch('/admin/services/service-123/deactivate'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.deactivateService('service-123');

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, 'Servicio desactivado exitosamente');
        verify(
          mockDioClient.patch('/admin/services/service-123/deactivate'),
        ).called(1);
      });

      test(
        'should return default message when no message in response',
        () async {
          // Arrange
          final responseData = {'success': true};

          when(
            mockDioClient.patch('/admin/services/service-123/deactivate'),
          ).thenAnswer((_) async => createResponse(responseData));

          // Act
          final result = await dataSource.deactivateService('service-123');

          // Assert
          expect(result.isRight, isTrue);
          expect(result.right, 'Servicio desactivado');
        },
      );

      test('should return default message when response is not Map', () async {
        // Arrange
        when(
          mockDioClient.patch('/admin/services/service-123/deactivate'),
        ).thenAnswer((_) async => createResponse('not a map'));

        // Act
        final result = await dataSource.deactivateService('service-123');

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, 'Servicio desactivado');
      });

      test('should return ErrorModel when success is false', () async {
        // Arrange
        final responseData = {
          'success': false,
          'code': 'ERR_DEACTIVATION',
          'message': 'No se pudo desactivar el servicio',
        };

        when(
          mockDioClient.patch('/admin/services/service-123/deactivate'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.deactivateService('service-123');

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel on DioException', () async {
        // Arrange
        when(
          mockDioClient.patch('/admin/services/service-123/deactivate'),
        ).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        // Act
        final result = await dataSource.deactivateService('service-123');

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel on generic exception', () async {
        // Arrange
        when(
          mockDioClient.patch('/admin/services/service-123/deactivate'),
        ).thenThrow(Exception('Network error'));

        // Act
        final result = await dataSource.deactivateService('service-123');

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });
    });
  });
}
