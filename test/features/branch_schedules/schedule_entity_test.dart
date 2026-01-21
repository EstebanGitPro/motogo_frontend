import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_entity.dart';

void main() {
  group('ScheduleEntity', () {
    group('constructor', () {
      test('should create entity with required fields', () {
        // Arrange & Act
        const entity = ScheduleEntity(
          id: 'schedule-123',
          branchId: 'branch-456',
          active: true,
        );

        // Assert
        expect(entity.id, equals('schedule-123'));
        expect(entity.branchId, equals('branch-456'));
        expect(entity.active, isTrue);
      });
    });

    group('copyWith', () {
      test('should copy with new active status', () {
        // Arrange
        const original = ScheduleEntity(
          id: 'schedule-123',
          branchId: 'branch-456',
          active: true,
        );

        // Act
        final copied = original.copyWith(active: false);

        // Assert
        expect(copied.id, equals(original.id));
        expect(copied.branchId, equals(original.branchId));
        expect(copied.active, isFalse);
      });

      test('should copy with new id', () {
        // Arrange
        const original = ScheduleEntity(
          id: 'schedule-123',
          branchId: 'branch-456',
          active: true,
        );

        // Act
        final copied = original.copyWith(id: 'new-id');

        // Assert
        expect(copied.id, equals('new-id'));
        expect(copied.branchId, equals(original.branchId));
        expect(copied.active, equals(original.active));
      });

      test('should return equivalent when no params provided', () {
        // Arrange
        const original = ScheduleEntity(
          id: 'schedule-123',
          branchId: 'branch-456',
          active: true,
        );

        // Act
        final copied = original.copyWith();

        // Assert
        expect(copied, equals(original));
      });
    });

    group('props', () {
      test('should include all fields in props', () {
        // Arrange
        const entity = ScheduleEntity(
          id: 'schedule-123',
          branchId: 'branch-456',
          active: true,
        );

        // Assert
        expect(entity.props, contains('schedule-123'));
        expect(entity.props, contains('branch-456'));
        expect(entity.props, contains(true));
        expect(
          entity.props.length,
          equals(5),
        ); // id, branchId, active, startDate, endDate
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        // Arrange
        const entity1 = ScheduleEntity(
          id: 'schedule-123',
          branchId: 'branch-456',
          active: true,
        );
        const entity2 = ScheduleEntity(
          id: 'schedule-123',
          branchId: 'branch-456',
          active: true,
        );

        // Assert
        expect(entity1, equals(entity2));
        expect(entity1.hashCode, equals(entity2.hashCode));
      });

      test('should not be equal when id differs', () {
        // Arrange
        const entity1 = ScheduleEntity(
          id: 'schedule-123',
          branchId: 'branch-456',
          active: true,
        );
        const entity2 = ScheduleEntity(
          id: 'schedule-other',
          branchId: 'branch-456',
          active: true,
        );

        // Assert
        expect(entity1, isNot(equals(entity2)));
      });

      test('should not be equal when active status differs', () {
        // Arrange
        const entity1 = ScheduleEntity(
          id: 'schedule-123',
          branchId: 'branch-456',
          active: true,
        );
        const entity2 = ScheduleEntity(
          id: 'schedule-123',
          branchId: 'branch-456',
          active: false,
        );

        // Assert
        expect(entity1, isNot(equals(entity2)));
      });
    });
  });
}
