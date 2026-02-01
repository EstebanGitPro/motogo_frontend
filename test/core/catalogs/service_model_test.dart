import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/catalogs/data/models/service_model.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/service_entity.dart';

void main() {
  group('ServiceModel', () {
    group('fromJson', () {
      test('should create model from complete JSON', () {
        final json = {
          'id': 'service-abc123',
          'name': 'Cambio de aceite',
          'description': 'Cambio completo de aceite de motor',
          'service_type': 'Mantenimiento',
        };

        final model = ServiceModel.fromJson(json);

        expect(model.id, 'service-abc123');
        expect(model.name, 'Cambio de aceite');
        expect(model.description, 'Cambio completo de aceite de motor');
        expect(model.serviceType, 'Mantenimiento');
      });

      test('should handle null values with defaults', () {
        final json = <String, dynamic>{};

        final model = ServiceModel.fromJson(json);

        expect(model.id, '');
        expect(model.name, '');
        expect(model.description, '');
        expect(model.serviceType, '');
      });

      test('should handle partial JSON with some null values', () {
        final json = {'id': 'test-id', 'name': 'Test Service'};

        final model = ServiceModel.fromJson(json);

        expect(model.id, 'test-id');
        expect(model.name, 'Test Service');
        expect(model.description, '');
        expect(model.serviceType, '');
      });
    });

    group('toEntity', () {
      test('should convert model to ServiceEntity', () {
        final model = ServiceModel(
          id: 'service-123',
          name: 'Alineación',
          description: 'Alineación de ruedas',
          serviceType: 'Mantenimiento preventivo',
        );

        final entity = model.toEntity();

        expect(entity, isA<ServiceEntity>());
        expect(entity.id, 'service-123');
        expect(entity.name, 'Alineación');
        expect(entity.description, 'Alineación de ruedas');
        expect(entity.serviceType, 'Mantenimiento preventivo');
      });
    });

    group('inheritance', () {
      test('should extend ServiceEntity', () {
        final model = ServiceModel(
          id: 'id',
          name: 'name',
          description: 'desc',
          serviceType: 'type',
        );

        expect(model, isA<ServiceEntity>());
      });
    });
  });
}
