import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/admin_services/data/models/admin_service_model.dart';
import 'package:motogo_frontend/src/features/admin_services/domain/entities/admin_service_entity.dart';

void main() {
  group('AdminServiceModel', () {
    group('fromJson', () {
      test('should create model from valid JSON with all fields', () {
        final json = {
          'id': 'service-123',
          'name': 'Cambio de aceite',
          'description': 'Cambio de aceite de motor',
          'service_type': 'Mantenimiento',
          'is_active': true,
        };

        final model = AdminServiceModel.fromJson(json);

        expect(model.id, 'service-123');
        expect(model.name, 'Cambio de aceite');
        expect(model.description, 'Cambio de aceite de motor');
        expect(model.serviceType, 'Mantenimiento');
        expect(model.isActive, true);
      });

      test('should handle null description', () {
        final json = {
          'id': 'service-123',
          'name': 'Cambio de aceite',
          'description': null,
          'service_type': 'Mantenimiento',
          'is_active': true,
        };

        final model = AdminServiceModel.fromJson(json);

        expect(model.description, isNull);
      });

      test('should handle missing description', () {
        final json = {
          'id': 'service-123',
          'name': 'Cambio de aceite',
          'service_type': 'Mantenimiento',
          'is_active': true,
        };

        final model = AdminServiceModel.fromJson(json);

        expect(model.description, isNull);
      });

      test('should parse is_active as bool true', () {
        final json = {
          'id': 'service-123',
          'name': 'Test',
          'service_type': 'Type',
          'is_active': true,
        };

        final model = AdminServiceModel.fromJson(json);

        expect(model.isActive, true);
      });

      test('should parse is_active as bool false', () {
        final json = {
          'id': 'service-123',
          'name': 'Test',
          'service_type': 'Type',
          'is_active': false,
        };

        final model = AdminServiceModel.fromJson(json);

        expect(model.isActive, false);
      });

      test('should parse is_active as int 1', () {
        final json = {
          'id': 'service-123',
          'name': 'Test',
          'service_type': 'Type',
          'is_active': 1,
        };

        final model = AdminServiceModel.fromJson(json);

        expect(model.isActive, true);
      });

      test('should parse is_active as int 0', () {
        final json = {
          'id': 'service-123',
          'name': 'Test',
          'service_type': 'Type',
          'is_active': 0,
        };

        final model = AdminServiceModel.fromJson(json);

        expect(model.isActive, false);
      });

      test('should parse is_active as string "true"', () {
        final json = {
          'id': 'service-123',
          'name': 'Test',
          'service_type': 'Type',
          'is_active': 'true',
        };

        final model = AdminServiceModel.fromJson(json);

        expect(model.isActive, true);
      });

      test('should parse is_active as string "false"', () {
        final json = {
          'id': 'service-123',
          'name': 'Test',
          'service_type': 'Type',
          'is_active': 'false',
        };

        final model = AdminServiceModel.fromJson(json);

        expect(model.isActive, false);
      });

      test('should parse is_active as string "1"', () {
        final json = {
          'id': 'service-123',
          'name': 'Test',
          'service_type': 'Type',
          'is_active': '1',
        };

        final model = AdminServiceModel.fromJson(json);

        expect(model.isActive, true);
      });

      test('should parse is_active as string "0"', () {
        final json = {
          'id': 'service-123',
          'name': 'Test',
          'service_type': 'Type',
          'is_active': '0',
        };

        final model = AdminServiceModel.fromJson(json);

        expect(model.isActive, false);
      });

      test('should default is_active to false for null', () {
        final json = {
          'id': 'service-123',
          'name': 'Test',
          'service_type': 'Type',
          'is_active': null,
        };

        final model = AdminServiceModel.fromJson(json);

        expect(model.isActive, false);
      });

      test('should use empty string for null id', () {
        final json = {
          'id': null,
          'name': 'Test',
          'service_type': 'Type',
          'is_active': true,
        };

        final model = AdminServiceModel.fromJson(json);

        expect(model.id, '');
      });

      test('should use empty string for null name', () {
        final json = {
          'id': 'service-123',
          'name': null,
          'service_type': 'Type',
          'is_active': true,
        };

        final model = AdminServiceModel.fromJson(json);

        expect(model.name, '');
      });

      test('should use empty string for null service_type', () {
        final json = {
          'id': 'service-123',
          'name': 'Test',
          'service_type': null,
          'is_active': true,
        };

        final model = AdminServiceModel.fromJson(json);

        expect(model.serviceType, '');
      });
    });

    group('fromEntity', () {
      test('should create model from entity with all fields', () {
        const entity = AdminServiceEntity(
          id: 'entity-123',
          name: 'Alineación',
          description: 'Alineación de ruedas',
          serviceType: 'Reparación',
          isActive: true,
        );

        final model = AdminServiceModel.fromEntity(entity);

        expect(model.id, 'entity-123');
        expect(model.name, 'Alineación');
        expect(model.description, 'Alineación de ruedas');
        expect(model.serviceType, 'Reparación');
        expect(model.isActive, true);
      });

      test('should create model from entity with null description', () {
        const entity = AdminServiceEntity(
          id: 'entity-123',
          name: 'Alineación',
          description: null,
          serviceType: 'Reparación',
          isActive: false,
        );

        final model = AdminServiceModel.fromEntity(entity);

        expect(model.description, isNull);
        expect(model.isActive, false);
      });
    });

    group('toJson', () {
      test('should convert model to JSON with all fields', () {
        const model = AdminServiceModel(
          id: 'service-123',
          name: 'Cambio de aceite',
          description: 'Cambio de aceite de motor',
          serviceType: 'Mantenimiento',
          isActive: true,
        );

        final json = model.toJson();

        expect(json['id'], 'service-123');
        expect(json['name'], 'Cambio de aceite');
        expect(json['description'], 'Cambio de aceite de motor');
        expect(json['service_type'], 'Mantenimiento');
        expect(json['is_active'], true);
      });

      test('should include null description in JSON', () {
        const model = AdminServiceModel(
          id: 'service-123',
          name: 'Cambio de aceite',
          description: null,
          serviceType: 'Mantenimiento',
          isActive: true,
        );

        final json = model.toJson();

        expect(json.containsKey('description'), true);
        expect(json['description'], isNull);
      });
    });

    group('toUpdateRequest', () {
      test('should create update request with required fields', () {
        const model = AdminServiceModel(
          id: 'service-123',
          name: 'Cambio de aceite',
          description: null,
          serviceType: 'Mantenimiento',
          isActive: true,
        );

        final request = model.toUpdateRequest();

        expect(request['name'], 'Cambio de aceite');
        expect(request['service_type'], 'Mantenimiento');
        expect(request['is_active'], true);
        expect(request.containsKey('description'), false);
      });

      test('should include description if not empty', () {
        const model = AdminServiceModel(
          id: 'service-123',
          name: 'Cambio de aceite',
          description: 'Cambio de aceite de motor',
          serviceType: 'Mantenimiento',
          isActive: true,
        );

        final request = model.toUpdateRequest();

        expect(request['description'], 'Cambio de aceite de motor');
      });

      test('should exclude empty description', () {
        const model = AdminServiceModel(
          id: 'service-123',
          name: 'Cambio de aceite',
          description: '',
          serviceType: 'Mantenimiento',
          isActive: false,
        );

        final request = model.toUpdateRequest();

        expect(request.containsKey('description'), false);
        expect(request['is_active'], false);
      });

      test('should not include id in update request', () {
        const model = AdminServiceModel(
          id: 'service-123',
          name: 'Test',
          serviceType: 'Type',
          isActive: true,
        );

        final request = model.toUpdateRequest();

        expect(request.containsKey('id'), false);
      });
    });
  });
}
