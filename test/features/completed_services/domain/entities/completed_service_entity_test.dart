import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/entities/completed_service_entity.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/entities/completed_service_item_entity.dart';

void main() {
  group('CompletedServiceEntity', () {
    final testDate = DateTime(2026, 2, 15, 10, 0);

    final testServices = [
      const CompletedServiceItemEntity(
        id: 'item-1',
        serviceId: 'svc-a',
        serviceName: 'Aceite',
        rating: 5,
        comment: 'Excelente',
      ),
      const CompletedServiceItemEntity(
        id: 'item-2',
        serviceId: 'svc-b',
        serviceName: 'Frenos',
      ),
    ];

    test('should create instance with all required fields', () {
      final entity = CompletedServiceEntity(
        id: 'svc-001',
        branchId: 'branch-123',
        motorcycleId: 'moto-456',
        status: 'PENDIENTE',
        requestDate: testDate,
      );

      expect(entity.id, 'svc-001');
      expect(entity.branchId, 'branch-123');
      expect(entity.motorcycleId, 'moto-456');
      expect(entity.status, 'PENDIENTE');
      expect(entity.requestDate, testDate);
      expect(entity.diagnosticId, isNull);
      expect(entity.quotedPrice, isNull);
      expect(entity.finalPrice, isNull);
      expect(entity.representativeNotes, isNull);
      expect(entity.services, isEmpty);
      expect(entity.branchName, isNull);
    });

    test('should create instance with all optional fields', () {
      final entity = CompletedServiceEntity(
        id: 'svc-001',
        branchId: 'branch-123',
        motorcycleId: 'moto-456',
        diagnosticId: 'diag-789',
        status: 'FINALIZADO',
        requestDate: testDate,
        quotedPrice: 185000,
        finalPrice: 175000,
        representativeNotes: 'Cambio de aceite',
        services: testServices,
        branchName: 'Sede Principal',
      );

      expect(entity.diagnosticId, 'diag-789');
      expect(entity.quotedPrice, 185000);
      expect(entity.finalPrice, 175000);
      expect(entity.representativeNotes, 'Cambio de aceite');
      expect(entity.services, hasLength(2));
      expect(entity.services[0].serviceId, 'svc-a');
      expect(entity.services[1].serviceId, 'svc-b');
      expect(entity.branchName, 'Sede Principal');
    });

    test('isFinalized should return true for FINALIZADO status', () {
      final entity = CompletedServiceEntity(
        id: 'svc-001',
        branchId: 'branch-123',
        motorcycleId: 'moto-456',
        status: 'FINALIZADO',
        requestDate: testDate,
      );

      expect(entity.isFinalized, isTrue);
    });

    test('hasUnratedItems should detect unrated service items', () {
      final entity = CompletedServiceEntity(
        id: 'svc-001',
        branchId: 'branch-123',
        motorcycleId: 'moto-456',
        status: 'FINALIZADO',
        requestDate: testDate,
        services: testServices,
      );

      expect(entity.hasUnratedItems, isTrue);
      expect(entity.ratedCount, 1);
    });

    test('props should include all fields', () {
      final entity = CompletedServiceEntity(
        id: 'svc-001',
        branchId: 'branch-123',
        motorcycleId: 'moto-456',
        diagnosticId: 'diag-789',
        status: 'FINALIZADO',
        requestDate: testDate,
        quotedPrice: 185000,
        finalPrice: 175000,
        representativeNotes: 'Notas',
        services: testServices,
        branchName: 'Sede',
      );

      expect(entity.props.length, 11);
    });

    test('two entities with same data should be equal', () {
      final entity1 = CompletedServiceEntity(
        id: 'svc-001',
        branchId: 'branch-123',
        motorcycleId: 'moto-456',
        status: 'PENDIENTE',
        requestDate: testDate,
      );
      final entity2 = CompletedServiceEntity(
        id: 'svc-001',
        branchId: 'branch-123',
        motorcycleId: 'moto-456',
        status: 'PENDIENTE',
        requestDate: testDate,
      );

      expect(entity1, equals(entity2));
    });

    test('two entities with different data should not be equal', () {
      final entity1 = CompletedServiceEntity(
        id: 'svc-001',
        branchId: 'branch-123',
        motorcycleId: 'moto-456',
        status: 'PENDIENTE',
        requestDate: testDate,
      );
      final entity2 = CompletedServiceEntity(
        id: 'svc-002',
        branchId: 'branch-456',
        motorcycleId: 'moto-789',
        status: 'FINALIZADO',
        requestDate: testDate,
      );

      expect(entity1, isNot(equals(entity2)));
    });
  });
}
