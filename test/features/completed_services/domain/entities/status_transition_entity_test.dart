import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/entities/status_transition_entity.dart';

void main() {
  group('StatusTransitionEntity', () {
    final testDate = DateTime(2026, 2, 16, 10, 30);

    test('should create instance with all required fields', () {
      final entity = StatusTransitionEntity(
        id: 'trans-1',
        previousStatus: 'PENDIENTE',
        newStatus: 'EN_PROCESO',
        createdBy: 'person-1',
        createdAt: testDate,
      );

      expect(entity.id, 'trans-1');
      expect(entity.previousStatus, 'PENDIENTE');
      expect(entity.newStatus, 'EN_PROCESO');
      expect(entity.createdBy, 'person-1');
      expect(entity.createdAt, testDate);
    });

    test('should allow null previousStatus (initial creation)', () {
      final entity = StatusTransitionEntity(
        id: 'trans-1',
        newStatus: 'PENDIENTE',
        createdBy: 'person-1',
        createdAt: testDate,
      );

      expect(entity.previousStatus, isNull);
      expect(entity.newStatus, 'PENDIENTE');
    });

    test('props should include all fields', () {
      final entity = StatusTransitionEntity(
        id: 'trans-1',
        previousStatus: 'PENDIENTE',
        newStatus: 'EN_PROCESO',
        createdBy: 'person-1',
        createdAt: testDate,
      );

      expect(entity.props.length, 5);
      expect(entity.props, contains('trans-1'));
      expect(entity.props, contains('PENDIENTE'));
      expect(entity.props, contains('EN_PROCESO'));
      expect(entity.props, contains('person-1'));
      expect(entity.props, contains(testDate));
    });

    test('two entities with same data should be equal', () {
      final entity1 = StatusTransitionEntity(
        id: 'trans-1',
        previousStatus: 'PENDIENTE',
        newStatus: 'EN_PROCESO',
        createdBy: 'person-1',
        createdAt: testDate,
      );
      final entity2 = StatusTransitionEntity(
        id: 'trans-1',
        previousStatus: 'PENDIENTE',
        newStatus: 'EN_PROCESO',
        createdBy: 'person-1',
        createdAt: testDate,
      );

      expect(entity1, equals(entity2));
    });

    test('two entities with different data should not be equal', () {
      final entity1 = StatusTransitionEntity(
        id: 'trans-1',
        newStatus: 'EN_PROCESO',
        createdBy: 'person-1',
        createdAt: testDate,
      );
      final entity2 = StatusTransitionEntity(
        id: 'trans-2',
        newStatus: 'FINALIZADO',
        createdBy: 'person-2',
        createdAt: testDate,
      );

      expect(entity1, isNot(equals(entity2)));
    });
  });
}
