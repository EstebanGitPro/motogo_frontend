import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/admin_services/domain/entities/admin_service_entity.dart';

void main() {
  group('AdminServiceEntity', () {
    group('constructor', () {
      test('should create entity with all required fields', () {
        const entity = AdminServiceEntity(
          id: 'service-123',
          name: 'Cambio de aceite',
          serviceType: 'Mantenimiento',
          isActive: true,
        );

        expect(entity.id, 'service-123');
        expect(entity.name, 'Cambio de aceite');
        expect(entity.description, isNull);
        expect(entity.serviceType, 'Mantenimiento');
        expect(entity.isActive, true);
      });

      test('should create entity with optional description', () {
        const entity = AdminServiceEntity(
          id: 'service-123',
          name: 'Cambio de aceite',
          description: 'Cambio de aceite de motor',
          serviceType: 'Mantenimiento',
          isActive: true,
        );

        expect(entity.description, 'Cambio de aceite de motor');
      });
    });

    group('copyWith', () {
      test('should copy with updated id', () {
        const original = AdminServiceEntity(
          id: 'service-123',
          name: 'Cambio de aceite',
          description: 'Descripción',
          serviceType: 'Mantenimiento',
          isActive: true,
        );

        final copy = original.copyWith(id: 'service-456');

        expect(copy.id, 'service-456');
        expect(copy.name, 'Cambio de aceite');
        expect(copy.description, 'Descripción');
        expect(copy.serviceType, 'Mantenimiento');
        expect(copy.isActive, true);
      });

      test('should copy with updated name', () {
        const original = AdminServiceEntity(
          id: 'service-123',
          name: 'Cambio de aceite',
          serviceType: 'Mantenimiento',
          isActive: true,
        );

        final copy = original.copyWith(name: 'Cambio de filtro');

        expect(copy.id, 'service-123');
        expect(copy.name, 'Cambio de filtro');
      });

      test('should copy with updated description', () {
        const original = AdminServiceEntity(
          id: 'service-123',
          name: 'Cambio de aceite',
          description: 'Descripción original',
          serviceType: 'Mantenimiento',
          isActive: true,
        );

        final copy = original.copyWith(description: 'Nueva descripción');

        expect(copy.description, 'Nueva descripción');
      });

      test('should copy with updated serviceType', () {
        const original = AdminServiceEntity(
          id: 'service-123',
          name: 'Cambio de aceite',
          serviceType: 'Mantenimiento',
          isActive: true,
        );

        final copy = original.copyWith(serviceType: 'Reparación');

        expect(copy.serviceType, 'Reparación');
      });

      test('should copy with updated isActive', () {
        const original = AdminServiceEntity(
          id: 'service-123',
          name: 'Test',
          serviceType: 'Type',
          isActive: true,
        );

        final copy = original.copyWith(isActive: false);

        expect(copy.isActive, false);
      });

      test('should return same values when no arguments provided', () {
        const original = AdminServiceEntity(
          id: 'service-123',
          name: 'Cambio de aceite',
          description: 'Descripción',
          serviceType: 'Mantenimiento',
          isActive: true,
        );

        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.name, original.name);
        expect(copy.description, original.description);
        expect(copy.serviceType, original.serviceType);
        expect(copy.isActive, original.isActive);
      });

      test('should copy with multiple updated fields', () {
        const original = AdminServiceEntity(
          id: 'service-123',
          name: 'Cambio de aceite',
          description: 'Descripción',
          serviceType: 'Mantenimiento',
          isActive: true,
        );

        final copy = original.copyWith(name: 'Nuevo nombre', isActive: false);

        expect(copy.id, 'service-123');
        expect(copy.name, 'Nuevo nombre');
        expect(copy.description, 'Descripción');
        expect(copy.serviceType, 'Mantenimiento');
        expect(copy.isActive, false);
      });
    });

    group('props', () {
      test('should include all fields in props', () {
        const entity = AdminServiceEntity(
          id: 'service-123',
          name: 'Cambio de aceite',
          description: 'Descripción',
          serviceType: 'Mantenimiento',
          isActive: true,
        );

        expect(entity.props, [
          'service-123',
          'Cambio de aceite',
          'Descripción',
          'Mantenimiento',
          true,
        ]);
      });

      test('should include null description in props', () {
        const entity = AdminServiceEntity(
          id: 'service-123',
          name: 'Test',
          serviceType: 'Type',
          isActive: false,
        );

        expect(entity.props, ['service-123', 'Test', null, 'Type', false]);
      });
    });

    group('equality', () {
      test('should be equal when all fields are same', () {
        const entity1 = AdminServiceEntity(
          id: 'service-123',
          name: 'Test',
          description: 'Desc',
          serviceType: 'Type',
          isActive: true,
        );
        const entity2 = AdminServiceEntity(
          id: 'service-123',
          name: 'Test',
          description: 'Desc',
          serviceType: 'Type',
          isActive: true,
        );

        expect(entity1, equals(entity2));
        expect(entity1.hashCode, equals(entity2.hashCode));
      });

      test('should not be equal when id differs', () {
        const entity1 = AdminServiceEntity(
          id: 'service-123',
          name: 'Test',
          serviceType: 'Type',
          isActive: true,
        );
        const entity2 = AdminServiceEntity(
          id: 'service-456',
          name: 'Test',
          serviceType: 'Type',
          isActive: true,
        );

        expect(entity1, isNot(equals(entity2)));
      });

      test('should not be equal when isActive differs', () {
        const entity1 = AdminServiceEntity(
          id: 'service-123',
          name: 'Test',
          serviceType: 'Type',
          isActive: true,
        );
        const entity2 = AdminServiceEntity(
          id: 'service-123',
          name: 'Test',
          serviceType: 'Type',
          isActive: false,
        );

        expect(entity1, isNot(equals(entity2)));
      });

      test('should not be equal when name differs', () {
        const entity1 = AdminServiceEntity(
          id: 'service-123',
          name: 'Test 1',
          serviceType: 'Type',
          isActive: true,
        );
        const entity2 = AdminServiceEntity(
          id: 'service-123',
          name: 'Test 2',
          serviceType: 'Type',
          isActive: true,
        );

        expect(entity1, isNot(equals(entity2)));
      });
    });
  });
}
