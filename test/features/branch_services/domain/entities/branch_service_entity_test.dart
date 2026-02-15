import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/branch_services/domain/entities/branch_service_entity.dart';

void main() {
  group('BranchServiceEntity', () {
    final testDate = DateTime(2025, 1, 15, 10, 30);

    test('should create entity with all required properties', () {
      final entity = BranchServiceEntity(
        id: 'service-1',
        name: 'Cambio de aceite',
        description: 'Cambio de aceite de motor',
        serviceType: 'Mantenimiento',
        addedAt: testDate,
        active: true,
      );

      expect(entity.id, 'service-1');
      expect(entity.name, 'Cambio de aceite');
      expect(entity.description, 'Cambio de aceite de motor');
      expect(entity.serviceType, 'Mantenimiento');
      expect(entity.addedAt, testDate);
      expect(entity.active, true);
    });

    test('should use default active = true and totalReviews = 0', () {
      const entity = BranchServiceEntity(
        id: 'service-1',
        name: 'Test',
        description: 'Desc',
        serviceType: 'Type',
      );

      expect(entity.active, true);
      expect(entity.averageRating, isNull);
      expect(entity.totalReviews, 0);
    });

    test('should allow null addedAt', () {
      const entity = BranchServiceEntity(
        id: 'service-1',
        name: 'Test',
        description: 'Desc',
        serviceType: 'Type',
        addedAt: null,
      );

      expect(entity.addedAt, isNull);
    });

    test('should create entity with rating fields', () {
      final entity = BranchServiceEntity(
        id: 'service-1',
        name: 'Test',
        description: 'Desc',
        serviceType: 'Type',
        addedAt: testDate,
        averageRating: 4.8,
        totalReviews: 120,
      );

      expect(entity.averageRating, 4.8);
      expect(entity.totalReviews, 120);
    });

    group('Equatable', () {
      test('two identical entities should be equal', () {
        final entity1 = BranchServiceEntity(
          id: 'service-1',
          name: 'Test',
          description: 'Desc',
          serviceType: 'Type',
          addedAt: testDate,
          active: true,
        );

        final entity2 = BranchServiceEntity(
          id: 'service-1',
          name: 'Test',
          description: 'Desc',
          serviceType: 'Type',
          addedAt: testDate,
          active: true,
        );

        expect(entity1, entity2);
      });

      test('entities with different id should not be equal', () {
        final entity1 = BranchServiceEntity(
          id: 'service-1',
          name: 'Test',
          description: 'Desc',
          serviceType: 'Type',
          addedAt: testDate,
        );

        final entity2 = BranchServiceEntity(
          id: 'service-2',
          name: 'Test',
          description: 'Desc',
          serviceType: 'Type',
          addedAt: testDate,
        );

        expect(entity1, isNot(entity2));
      });

      test('entities with different active should not be equal', () {
        final entity1 = BranchServiceEntity(
          id: 'service-1',
          name: 'Test',
          description: 'Desc',
          serviceType: 'Type',
          addedAt: testDate,
          active: true,
        );

        final entity2 = BranchServiceEntity(
          id: 'service-1',
          name: 'Test',
          description: 'Desc',
          serviceType: 'Type',
          addedAt: testDate,
          active: false,
        );

        expect(entity1, isNot(entity2));
      });

      test('props should contain all fields', () {
        final entity = BranchServiceEntity(
          id: 'service-1',
          name: 'Test',
          description: 'Desc',
          serviceType: 'Type',
          addedAt: testDate,
          active: true,
        );

        expect(entity.props.length, 8);
      });
    });
  });
}
