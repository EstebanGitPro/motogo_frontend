import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/branch_detail/domain/entities/branch_detail_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_detail_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_exception_entity.dart';

void main() {
  const baseEntity = BranchDetailEntity(
    id: 'branch-1',
    name: 'Taller Central',
    type: 'taller',
    latitude: 4.6,
    longitude: -74.0,
    address: 'Calle 1',
    cityName: 'Bogotá',
    departmentName: 'Cundinamarca',
  );

  group('BranchDetailEntity', () {
    group('type getters', () {
      test('isWorkshop should return true for taller type', () {
        expect(baseEntity.isWorkshop, isTrue);
        expect(baseEntity.isStore, isFalse);
        expect(baseEntity.isWorkshopStore, isFalse);
      });

      test('isStore should return true for tienda type', () {
        const storeEntity = BranchDetailEntity(
          id: '1',
          name: 'Test',
          type: 'tienda',
          latitude: 0,
          longitude: 0,
        );
        expect(storeEntity.isStore, isTrue);
        expect(storeEntity.isWorkshop, isFalse);
      });

      test('isWorkshopStore should return true for taller_tienda type', () {
        const combo = BranchDetailEntity(
          id: '1',
          name: 'Test',
          type: 'taller_tienda',
          latitude: 0,
          longitude: 0,
        );
        expect(combo.isWorkshopStore, isTrue);
      });
    });

    group('displayTypeLabel', () {
      test('should return typeLabel when provided', () {
        const entity = BranchDetailEntity(
          id: '1',
          name: 'Test',
          type: 'taller',
          typeLabel: 'Centro de Servicio',
          latitude: 0,
          longitude: 0,
        );
        expect(entity.displayTypeLabel, 'Centro de Servicio');
      });

      test('should return Taller for workshop type without label', () {
        expect(baseEntity.displayTypeLabel, 'Taller');
      });

      test('should return Taller y Tienda for combo type without label', () {
        const entity = BranchDetailEntity(
          id: '1',
          name: 'Test',
          type: 'taller_tienda',
          latitude: 0,
          longitude: 0,
        );
        expect(entity.displayTypeLabel, 'Taller y Tienda');
      });

      test('should return Tienda for store type without label', () {
        const entity = BranchDetailEntity(
          id: '1',
          name: 'Test',
          type: 'tienda',
          latitude: 0,
          longitude: 0,
        );
        expect(entity.displayTypeLabel, 'Tienda');
      });

      test('should return Tienda for unknown type without label', () {
        const entity = BranchDetailEntity(
          id: '1',
          name: 'Test',
          type: 'unknown',
          latitude: 0,
          longitude: 0,
        );
        expect(entity.displayTypeLabel, 'Tienda');
      });
    });

    group('fullAddress', () {
      test('should combine address and city', () {
        expect(baseEntity.fullAddress, 'Calle 1, Bogotá');
      });

      test('should return only address when city is null', () {
        const entity = BranchDetailEntity(
          id: '1',
          name: 'Test',
          type: 'taller',
          latitude: 0,
          longitude: 0,
          address: 'Calle 1',
        );
        expect(entity.fullAddress, 'Calle 1');
      });

      test('should return only city when address is null', () {
        const entity = BranchDetailEntity(
          id: '1',
          name: 'Test',
          type: 'taller',
          latitude: 0,
          longitude: 0,
          cityName: 'Bogotá',
        );
        expect(entity.fullAddress, 'Bogotá');
      });

      test('should return empty string when both are null', () {
        const entity = BranchDetailEntity(
          id: '1',
          name: 'Test',
          type: 'taller',
          latitude: 0,
          longitude: 0,
        );
        expect(entity.fullAddress, '');
      });

      test('should skip empty address', () {
        const entity = BranchDetailEntity(
          id: '1',
          name: 'Test',
          type: 'taller',
          latitude: 0,
          longitude: 0,
          address: '',
          cityName: 'Bogotá',
        );
        expect(entity.fullAddress, 'Bogotá');
      });
    });

    group('isOpenNow', () {
      test('should return false when no schedules for today', () {
        final result = baseEntity.isOpenNow([]);
        expect(result, isFalse);
      });

      test('should return false when today schedule is closed', () {
        final now = DateTime.now();
        final schedules = [
          ScheduleDetailEntity(
            id: '1',
            scheduleId: 's1',
            dayOfWeek: now.weekday,
            dayName: 'Test',
            openingTime: '08:00',
            closingTime: '18:00',
            isClosed: true,
            active: true,
          ),
        ];
        final result = baseEntity.isOpenNow(schedules);
        expect(result, isFalse);
      });

      test('should return true when within opening hours', () {
        final now = DateTime.now();
        final schedules = [
          ScheduleDetailEntity(
            id: '1',
            scheduleId: 's1',
            dayOfWeek: now.weekday,
            dayName: 'Test',
            openingTime: '00:00',
            closingTime: '23:59',
            isClosed: false,
            active: true,
          ),
        ];
        final result = baseEntity.isOpenNow(schedules);
        expect(result, isTrue);
      });

      test('should return false when outside opening hours', () {
        final now = DateTime.now();
        // Set time far from current
        final earlyHour = (now.hour + 2) % 24;
        final lateHour = (now.hour + 3) % 24;
        final schedules = [
          ScheduleDetailEntity(
            id: '1',
            scheduleId: 's1',
            dayOfWeek: now.weekday,
            dayName: 'Test',
            openingTime: '${earlyHour.toString().padLeft(2, '0')}:00',
            closingTime: '${lateHour.toString().padLeft(2, '0')}:00',
            isClosed: false,
            active: true,
          ),
        ];
        final result = baseEntity.isOpenNow(schedules);
        expect(result, isFalse);
      });

      test('should return false when closed by exception', () {
        final now = DateTime.now();
        final today =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        final schedules = [
          ScheduleDetailEntity(
            id: '1',
            scheduleId: 's1',
            dayOfWeek: now.weekday,
            dayName: 'Test',
            openingTime: '00:00',
            closingTime: '23:59',
            isClosed: false,
            active: true,
          ),
        ];
        final exceptions = [
          ScheduleExceptionEntity(
            id: 'e1',
            scheduleId: 's1',
            exceptionStartDate: today,
            exceptionEndDate: today,
            exceptionStartDateFormatted: 'Today',
            dayName: 'Test',
            openingTime: '',
            closingTime: '',
            isClosed: true,
            active: true,
          ),
        ];
        final result = baseEntity.isOpenNow(schedules, exceptions);
        expect(result, isFalse);
      });

      test('should use exception hours when exception has custom schedule', () {
        final now = DateTime.now();
        final today =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        final exceptions = [
          ScheduleExceptionEntity(
            id: 'e1',
            scheduleId: 's1',
            exceptionStartDate: today,
            exceptionEndDate: today,
            exceptionStartDateFormatted: 'Today',
            dayName: 'Test',
            openingTime: '00:00',
            closingTime: '23:59',
            isClosed: false,
            active: true,
          ),
        ];
        final result = baseEntity.isOpenNow([], exceptions);
        expect(result, isTrue);
      });

      test('should skip inactive exceptions', () {
        final now = DateTime.now();
        final today =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        final schedules = [
          ScheduleDetailEntity(
            id: '1',
            scheduleId: 's1',
            dayOfWeek: now.weekday,
            dayName: 'Test',
            openingTime: '00:00',
            closingTime: '23:59',
            isClosed: false,
            active: true,
          ),
        ];
        final exceptions = [
          ScheduleExceptionEntity(
            id: 'e1',
            scheduleId: 's1',
            exceptionStartDate: today,
            exceptionEndDate: today,
            exceptionStartDateFormatted: 'Today',
            dayName: 'Test',
            openingTime: '',
            closingTime: '',
            isClosed: true,
            active: false,
          ),
        ];
        final result = baseEntity.isOpenNow(schedules, exceptions);
        // Should still be open since the exception is inactive
        expect(result, isTrue);
      });

      test('should skip exceptions with invalid dates', () {
        final now = DateTime.now();
        final schedules = [
          ScheduleDetailEntity(
            id: '1',
            scheduleId: 's1',
            dayOfWeek: now.weekday,
            dayName: 'Test',
            openingTime: '00:00',
            closingTime: '23:59',
            isClosed: false,
            active: true,
          ),
        ];
        final exceptions = [
          const ScheduleExceptionEntity(
            id: 'e1',
            scheduleId: 's1',
            exceptionStartDate: 'invalid-date',
            exceptionEndDate: 'invalid-date',
            exceptionStartDateFormatted: 'Invalid',
            dayName: 'Test',
            openingTime: '',
            closingTime: '',
            isClosed: true,
            active: true,
          ),
        ];
        final result = baseEntity.isOpenNow(schedules, exceptions);
        expect(result, isTrue);
      });

      test('should handle schedule with invalid time format', () {
        final now = DateTime.now();
        final schedules = [
          ScheduleDetailEntity(
            id: '1',
            scheduleId: 's1',
            dayOfWeek: now.weekday,
            dayName: 'Test',
            openingTime: 'invalid',
            closingTime: 'invalid',
            isClosed: false,
            active: true,
          ),
        ];
        final result = baseEntity.isOpenNow(schedules);
        expect(result, isFalse);
      });
    });

    group('getTodaySchedule', () {
      test('should return No disponible when no schedules', () {
        final result = baseEntity.getTodaySchedule([]);
        expect(result, 'No disponible');
      });

      test('should return time range from active schedule', () {
        final now = DateTime.now();
        final schedules = [
          ScheduleDetailEntity(
            id: '1',
            scheduleId: 's1',
            dayOfWeek: now.weekday,
            dayName: 'Test',
            openingTime: '08:00',
            closingTime: '18:00',
            isClosed: false,
            active: true,
          ),
        ];
        final result = baseEntity.getTodaySchedule(schedules);
        expect(result, '08:00 - 18:00');
      });

      test('should return Cerrado when schedule is closed', () {
        final now = DateTime.now();
        final schedules = [
          ScheduleDetailEntity(
            id: '1',
            scheduleId: 's1',
            dayOfWeek: now.weekday,
            dayName: 'Test',
            openingTime: '08:00',
            closingTime: '18:00',
            isClosed: true,
            active: true,
          ),
        ];
        final result = baseEntity.getTodaySchedule(schedules);
        expect(result, 'Cerrado');
      });

      test('should prefer non-closed schedule', () {
        final now = DateTime.now();
        final schedules = [
          ScheduleDetailEntity(
            id: '1',
            scheduleId: 's1',
            dayOfWeek: now.weekday,
            dayName: 'Test',
            openingTime: '',
            closingTime: '',
            isClosed: true,
            active: true,
          ),
          ScheduleDetailEntity(
            id: '2',
            scheduleId: 's1',
            dayOfWeek: now.weekday,
            dayName: 'Test',
            openingTime: '09:00',
            closingTime: '17:00',
            isClosed: false,
            active: true,
          ),
        ];
        final result = baseEntity.getTodaySchedule(schedules);
        expect(result, '09:00 - 17:00');
      });
    });

    group('props', () {
      test('should include all fields', () {
        expect(baseEntity.props, hasLength(12));
      });

      test('should be equal for same values', () {
        const entity1 = BranchDetailEntity(
          id: '1',
          name: 'Test',
          type: 'taller',
          latitude: 4.6,
          longitude: -74.0,
        );
        const entity2 = BranchDetailEntity(
          id: '1',
          name: 'Test',
          type: 'taller',
          latitude: 4.6,
          longitude: -74.0,
        );
        expect(entity1, equals(entity2));
      });
    });
  });
}
