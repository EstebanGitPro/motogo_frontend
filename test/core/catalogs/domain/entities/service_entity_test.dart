import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/service_entity.dart';

void main() {
  group('ServiceEntity', () {
    group('constructor', () {
      test('should create instance with all required fields', () {
        // Act
        const entity = ServiceEntity(
          id: 'service-123',
          name: 'Cambio de Aceite',
          description: 'Servicio de cambio de aceite',
          serviceType: 'maintenance',
        );

        // Assert
        expect(entity.id, 'service-123');
        expect(entity.name, 'Cambio de Aceite');
        expect(entity.description, 'Servicio de cambio de aceite');
        expect(entity.serviceType, 'maintenance');
      });

      test('should support const constructor', () {
        // Act & Assert
        const entity = ServiceEntity(
          id: 'id',
          name: 'name',
          description: 'desc',
          serviceType: 'type',
        );
        expect(entity, isA<ServiceEntity>());
      });
    });

    group('Equatable', () {
      test('should be equal when all properties match', () {
        // Arrange
        const entity1 = ServiceEntity(
          id: 'service-1',
          name: 'Service',
          description: 'Desc',
          serviceType: 'type',
        );
        const entity2 = ServiceEntity(
          id: 'service-1',
          name: 'Service',
          description: 'Desc',
          serviceType: 'type',
        );

        // Assert
        expect(entity1, equals(entity2));
        expect(entity1.hashCode, equals(entity2.hashCode));
      });

      test('should not be equal when id differs', () {
        // Arrange
        const entity1 = ServiceEntity(
          id: 'service-1',
          name: 'S',
          description: 'D',
          serviceType: 'T',
        );
        const entity2 = ServiceEntity(
          id: 'service-2',
          name: 'S',
          description: 'D',
          serviceType: 'T',
        );

        // Assert
        expect(entity1, isNot(equals(entity2)));
      });

      test('props should include all fields', () {
        // Arrange
        const entity = ServiceEntity(
          id: 'id',
          name: 'name',
          description: 'desc',
          serviceType: 'type',
        );

        // Assert
        expect(entity.props.length, 4);
        expect(entity.props, contains('id'));
        expect(entity.props, contains('name'));
        expect(entity.props, contains('desc'));
        expect(entity.props, contains('type'));
      });
    });
  });
}
