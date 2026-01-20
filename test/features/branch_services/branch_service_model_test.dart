import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/branch_services/data/models/branch_service_model.dart';
import 'package:motogo_frontend/src/features/branch_services/domain/entities/branch_service_entity.dart';

void main() {
  group('BranchServiceModel', () {
    group('fromJson', () {
      test('parses valid JSON correctly', () {
        // Arrange
        final json = {
          'id': 'service-123',
          'name': 'Cambio de aceite',
          'description': 'Cambio de aceite de motor',
          'service_type': 'Mantenimiento',
          'added_at': '2026-01-16T17:14:06-05:00',
          'active': true,
        };

        // Act
        final model = BranchServiceModel.fromJson(json);

        // Assert
        expect(model.id, 'service-123');
        expect(model.name, 'Cambio de aceite');
        expect(model.description, 'Cambio de aceite de motor');
        expect(model.serviceType, 'Mantenimiento');
        expect(model.active, true);
        expect(model.addedAt, isNotNull);
      });

      test('handles null added_at gracefully', () {
        // Arrange
        final json = {
          'id': 'service-123',
          'name': 'Cambio de aceite',
          'description': 'Cambio de aceite de motor',
          'service_type': 'Mantenimiento',
          'added_at': null,
          'active': true,
        };

        // Act
        final model = BranchServiceModel.fromJson(json);

        // Assert
        expect(model.addedAt, isNull);
      });

      test('handles missing optional fields', () {
        // Arrange
        final json = {
          'id': 'service-123',
          'name': 'Test Service',
          'description': '',
          'service_type': 'General',
          'active': false,
        };

        // Act
        final model = BranchServiceModel.fromJson(json);

        // Assert
        expect(model.id, 'service-123');
        expect(model.description, '');
        expect(model.active, false);
        expect(model.addedAt, isNull);
      });
    });

    group('toEntity', () {
      test('converts model to entity correctly', () {
        // Arrange
        final model = BranchServiceModel(
          id: 'service-123',
          name: 'Cambio de aceite',
          description: 'Test description',
          serviceType: 'Mantenimiento',
          addedAt: DateTime(2026, 1, 16),
          active: true,
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity, isA<BranchServiceEntity>());
        expect(entity.id, 'service-123');
        expect(entity.name, 'Cambio de aceite');
        expect(entity.description, 'Test description');
        expect(entity.serviceType, 'Mantenimiento');
        expect(entity.addedAt, DateTime(2026, 1, 16));
        expect(entity.active, true);
      });
    });
  });

  group('BranchServiceEntity', () {
    test('creates entity with all required fields', () {
      // Arrange & Act
      final entity = BranchServiceEntity(
        id: 'entity-123',
        name: 'Test Service',
        description: 'Test description',
        serviceType: 'Reparación',
        addedAt: DateTime.now(),
        active: true,
      );

      // Assert
      expect(entity.id, 'entity-123');
      expect(entity.name, 'Test Service');
      expect(entity.serviceType, 'Reparación');
      expect(entity.active, true);
    });

    test('supports null addedAt', () {
      // Arrange & Act
      final entity = BranchServiceEntity(
        id: 'entity-123',
        name: 'Test Service',
        description: 'Test description',
        serviceType: 'Reparación',
        addedAt: null,
        active: false,
      );

      // Assert
      expect(entity.addedAt, isNull);
      expect(entity.active, false);
    });
  });
}
