import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/entities/completed_service_item_entity.dart';

void main() {
  group('CompletedServiceItemEntity', () {
    test('isRated returns true when rating is present', () {
      const entity = CompletedServiceItemEntity(
        id: 'item-1',
        serviceId: 'svc-1',
        serviceName: 'Cambio de aceite',
        rating: 5,
        comment: 'Excelente',
        ratedAt: '2025-01-15T10:00:00Z',
      );

      expect(entity.isRated, isTrue);
      expect(entity.canRate, isFalse);
    });

    test('isRated returns false when rating is null', () {
      const entity = CompletedServiceItemEntity(
        id: 'item-2',
        serviceId: 'svc-2',
        serviceName: 'Revisión general',
      );

      expect(entity.isRated, isFalse);
      expect(entity.canRate, isTrue);
    });

    test('canRate returns true when not yet rated', () {
      const entity = CompletedServiceItemEntity(
        id: 'item-3',
        serviceId: 'svc-3',
      );

      expect(entity.canRate, isTrue);
    });

    test('canRate returns false when already rated', () {
      const entity = CompletedServiceItemEntity(
        id: 'item-4',
        serviceId: 'svc-4',
        rating: 3,
      );

      expect(entity.canRate, isFalse);
    });

    test('props includes all fields', () {
      const entity = CompletedServiceItemEntity(
        id: 'item-5',
        serviceId: 'svc-5',
        serviceName: 'Lavado',
        rating: 4,
        comment: 'Bien',
        ratedAt: '2025-02-01',
      );

      expect(entity.props, [
        'item-5',
        'svc-5',
        'Lavado',
        4,
        'Bien',
        '2025-02-01',
      ]);
    });

    test('two entities with same values are equal', () {
      const entity1 = CompletedServiceItemEntity(
        id: 'item-1',
        serviceId: 'svc-1',
      );
      const entity2 = CompletedServiceItemEntity(
        id: 'item-1',
        serviceId: 'svc-1',
      );

      expect(entity1, equals(entity2));
    });

    test('nullable fields default to null', () {
      const entity = CompletedServiceItemEntity(
        id: 'item-1',
        serviceId: 'svc-1',
      );

      expect(entity.serviceName, isNull);
      expect(entity.rating, isNull);
      expect(entity.comment, isNull);
      expect(entity.ratedAt, isNull);
    });
  });
}
