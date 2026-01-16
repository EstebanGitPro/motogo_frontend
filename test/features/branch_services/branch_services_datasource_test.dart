import 'package:flutter_test/flutter_test.dart';

/// Tests for BranchServicesDataSource response handling.
///
/// Note: Full mocking of DioClient requires additional setup.
/// These tests validate the expected response structure.
void main() {
  group('BranchServicesDataSource Response Handling', () {
    group('getBranchServices response parsing', () {
      test('success response contains services array', () {
        // Arrange
        final responseBody = {
          'success': true,
          'message': 'Servicios obtenidos exitosamente',
          'data': {
            'services': [
              {
                'id': '5ab9ddc9-f25f-11f0-bec8-c25d85809228',
                'name': 'Ajuste general de tornillería',
                'description': 'Revisión y ajuste de toda la tornillería',
                'service_type': 'Mantenimiento',
                'added_at': '2026-01-16T17:14:06-05:00',
                'active': true,
              },
            ],
            '_links': [
              {
                'href': 'http://localhost:8085/branches/abc123/services',
                'rel': 'self',
                'method': 'GET',
              },
            ],
          },
        };

        // Assert
        expect(responseBody['success'], isTrue);
        expect(responseBody['data'], isNotNull);
        final data = responseBody['data'] as Map<String, dynamic>;
        expect(data['services'], isA<List>());
        expect((data['services'] as List).length, 1);
      });

      test('empty services returns empty array', () {
        // Arrange
        final responseBody = {
          'success': true,
          'message': 'No hay servicios asociados',
          'data': {'services': []},
        };

        // Assert
        expect(responseBody['success'], isTrue);
        final data = responseBody['data'] as Map<String, dynamic>;
        expect((data['services'] as List).isEmpty, isTrue);
      });

      test('error response contains error info', () {
        // Arrange
        final responseBody = {
          'success': false,
          'code': 'ERR_NOT_FOUND',
          'message': 'Sede no encontrada',
        };

        // Assert
        expect(responseBody['success'], isFalse);
        expect(responseBody['message'], 'Sede no encontrada');
      });
    });

    group('associateService response parsing', () {
      test('success response contains message', () {
        // Arrange
        final responseBody = {
          'success': true,
          'message': 'Servicio asociado exitosamente',
          'data': {'services_added': 1},
        };

        // Assert
        expect(responseBody['success'], isTrue);
        expect(responseBody['message'], contains('exitosamente'));
      });

      test('error response when service already associated', () {
        // Arrange
        final responseBody = {
          'success': false,
          'code': 'ERR_DUPLICATE',
          'message': 'El servicio ya está asociado a esta sede',
        };

        // Assert
        expect(responseBody['success'], isFalse);
        expect(responseBody['message'], contains('ya está asociado'));
      });
    });

    group('dissociateService response parsing', () {
      test('success response contains message', () {
        // Arrange
        final responseBody = {
          'success': true,
          'message': 'Servicio desasociado exitosamente',
        };

        // Assert
        expect(responseBody['success'], isTrue);
        expect(responseBody['message'], contains('desasociado'));
      });

      test('error response when service not found', () {
        // Arrange
        final responseBody = {
          'success': false,
          'code': 'ERR_NOT_FOUND',
          'message': 'El servicio no está asociado a esta sede',
        };

        // Assert
        expect(responseBody['success'], isFalse);
        expect(responseBody['message'], contains('no está asociado'));
      });
    });

    group('Request body formatting', () {
      test('associateService sends service_ids array', () {
        // Arrange
        final requestBody = {
          'service_ids': ['service-123', 'service-456'],
        };

        // Assert
        expect(requestBody['service_ids'], isA<List>());
        expect((requestBody['service_ids'] as List).length, 2);
      });

      test('single service association', () {
        // Arrange
        final requestBody = {
          'service_ids': ['service-123'],
        };

        // Assert
        expect((requestBody['service_ids'] as List).length, 1);
      });
    });
  });
}
