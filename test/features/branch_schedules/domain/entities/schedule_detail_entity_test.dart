import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_detail_entity.dart';

void main() {
  group('ScheduleDetailEntity', () {
    const entity = ScheduleDetailEntity(
      id: 'detail-1',
      scheduleId: 'schedule-1',
      dayOfWeek: 1,
      dayName: 'Lunes',
      openingTime: '08:00',
      closingTime: '18:00',
      isClosed: false,
      active: true,
    );

    test('should create entity with required properties', () {
      expect(entity.id, 'detail-1');
      expect(entity.scheduleId, 'schedule-1');
      expect(entity.dayOfWeek, 1);
      expect(entity.dayName, 'Lunes');
      expect(entity.openingTime, '08:00');
      expect(entity.closingTime, '18:00');
      expect(entity.isClosed, false);
      expect(entity.active, true);
    });

    group('copyWith', () {
      test('should return same entity when no args provided', () {
        final copy = entity.copyWith();
        expect(copy, entity);
      });

      test('should copy with new id', () {
        final copy = entity.copyWith(id: 'detail-2');
        expect(copy.id, 'detail-2');
        expect(copy.scheduleId, entity.scheduleId);
      });

      test('should copy with new scheduleId', () {
        final copy = entity.copyWith(scheduleId: 'schedule-2');
        expect(copy.scheduleId, 'schedule-2');
      });

      test('should copy with new dayOfWeek', () {
        final copy = entity.copyWith(dayOfWeek: 5);
        expect(copy.dayOfWeek, 5);
      });

      test('should copy with new dayName', () {
        final copy = entity.copyWith(dayName: 'Viernes');
        expect(copy.dayName, 'Viernes');
      });

      test('should copy with new openingTime', () {
        final copy = entity.copyWith(openingTime: '09:00');
        expect(copy.openingTime, '09:00');
      });

      test('should copy with new closingTime', () {
        final copy = entity.copyWith(closingTime: '17:00');
        expect(copy.closingTime, '17:00');
      });

      test('should copy with new isClosed', () {
        final copy = entity.copyWith(isClosed: true);
        expect(copy.isClosed, true);
      });

      test('should copy with new active', () {
        final copy = entity.copyWith(active: false);
        expect(copy.active, false);
      });
    });

    group('displayTimeRange', () {
      test('should return time range when open', () {
        expect(entity.displayTimeRange, '08:00 - 18:00');
      });

      test('should return Cerrado when closed', () {
        final closed = entity.copyWith(isClosed: true);
        expect(closed.displayTimeRange, 'Cerrado');
      });
    });

    group('Equatable', () {
      test('two identical entities should be equal', () {
        const other = ScheduleDetailEntity(
          id: 'detail-1',
          scheduleId: 'schedule-1',
          dayOfWeek: 1,
          dayName: 'Lunes',
          openingTime: '08:00',
          closingTime: '18:00',
          isClosed: false,
          active: true,
        );
        expect(entity, other);
      });

      test('different entities should not be equal', () {
        final other = entity.copyWith(id: 'detail-other');
        expect(entity, isNot(other));
      });

      test('props should contain all fields', () {
        expect(entity.props.length, 8);
      });
    });
  });
}
