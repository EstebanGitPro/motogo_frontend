import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/branch_schedules/data/models/schedule_model.dart';

void main() {
  group('ScheduleModel', () {
    group('fromJson', () {
      test('should correctly parse complete JSON', () {
        // Arrange
        final json = {
          'id': 'schedule-123',
          'branch_id': 'branch-456',
          'active': true,
        };

        // Act
        final result = ScheduleModel.fromJson(json);

        // Assert
        expect(result.id, equals('schedule-123'));
        expect(result.branchId, equals('branch-456'));
        expect(result.active, isTrue);
      });

      test('should handle inactive schedule', () {
        // Arrange
        final json = {
          'id': 'schedule-123',
          'branch_id': 'branch-456',
          'active': false,
        };

        // Act
        final result = ScheduleModel.fromJson(json);

        // Assert
        expect(result.active, isFalse);
      });

      test('should handle null values with defaults', () {
        // Arrange
        final json = <String, dynamic>{};

        // Act
        final result = ScheduleModel.fromJson(json);

        // Assert
        expect(result.id, equals(''));
        expect(result.branchId, equals(''));
        expect(result.active, isTrue); // Default to true
      });

      test('should handle numeric id values', () {
        // Arrange
        final json = {'id': 123, 'branch_id': 456, 'active': true};

        // Act
        final result = ScheduleModel.fromJson(json);

        // Assert
        expect(result.id, equals('123'));
        expect(result.branchId, equals('456'));
      });
    });

    group('toJson', () {
      test('should correctly serialize to JSON', () {
        // Arrange
        const model = ScheduleModel(
          id: 'schedule-123',
          branchId: 'branch-456',
          active: true,
        );

        // Act
        final result = model.toJson();

        // Assert
        expect(result['id'], equals('schedule-123'));
        expect(result['branch_id'], equals('branch-456'));
        expect(result['active'], isTrue);
      });

      test('should serialize inactive schedule', () {
        // Arrange
        const model = ScheduleModel(
          id: 'schedule-123',
          branchId: 'branch-456',
          active: false,
        );

        // Act
        final result = model.toJson();

        // Assert
        expect(result['active'], isFalse);
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        // Arrange
        const model1 = ScheduleModel(
          id: 'schedule-123',
          branchId: 'branch-456',
          active: true,
        );
        const model2 = ScheduleModel(
          id: 'schedule-123',
          branchId: 'branch-456',
          active: true,
        );

        // Assert
        expect(model1, equals(model2));
        expect(model1.hashCode, equals(model2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        const model1 = ScheduleModel(
          id: 'schedule-123',
          branchId: 'branch-456',
          active: true,
        );
        const model2 = ScheduleModel(
          id: 'schedule-123',
          branchId: 'branch-456',
          active: false,
        );

        // Assert
        expect(model1, isNot(equals(model2)));
      });
    });
  });
}
