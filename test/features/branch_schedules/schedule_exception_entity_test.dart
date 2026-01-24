import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_exception_entity.dart';

void main() {
  group('ScheduleExceptionEntity', () {
    group('constructor', () {
      test('should create entity with required fields', () {
        // Arrange & Act
        const entity = ScheduleExceptionEntity(
          id: 'exception-123',
          scheduleId: 'schedule-456',
          exceptionStartDate: '2026-12-24',
          exceptionEndDate: '2026-12-24',
          exceptionStartDateFormatted: '24 de Diciembre, 2026',
          dayName: 'Martes',
          openingTime: '09:00',
          closingTime: '14:00',
          isClosed: false,
          active: true,
        );

        // Assert
        expect(entity.id, equals('exception-123'));
        expect(entity.scheduleId, equals('schedule-456'));
        expect(entity.exceptionStartDate, equals('2026-12-24'));
        expect(entity.exceptionEndDate, equals('2026-12-24'));
        expect(
          entity.exceptionStartDateFormatted,
          equals('24 de Diciembre, 2026'),
        );
        expect(entity.dayName, equals('Martes'));
        expect(entity.openingTime, equals('09:00'));
        expect(entity.closingTime, equals('14:00'));
        expect(entity.isClosed, isFalse);
        expect(entity.active, isTrue);
      });

      test('should create date range entity', () {
        // Arrange & Act
        const entity = ScheduleExceptionEntity(
          id: 'exception-123',
          scheduleId: 'schedule-456',
          exceptionStartDate: '2026-12-24',
          exceptionEndDate: '2026-12-31',
          exceptionStartDateFormatted: '24 de Diciembre, 2026',
          exceptionEndDateFormatted: '31 de Diciembre, 2026',
          dayName: 'Martes',
          openingTime: '09:00',
          closingTime: '14:00',
          isClosed: false,
          active: true,
        );

        // Assert
        expect(entity.isDateRange, isTrue);
        expect(
          entity.exceptionEndDateFormatted,
          equals('31 de Diciembre, 2026'),
        );
      });
    });

    group('displayTimeRange', () {
      test('should return time range when not closed', () {
        // Arrange
        const entity = ScheduleExceptionEntity(
          id: 'exc-1',
          scheduleId: 'sch-1',
          exceptionStartDate: '2026-12-24',
          exceptionEndDate: '2026-12-24',
          exceptionStartDateFormatted: '24 de Diciembre, 2026',
          dayName: 'Martes',
          openingTime: '09:00',
          closingTime: '14:00',
          isClosed: false,
          active: true,
        );

        // Assert
        expect(entity.displayTimeRange, equals('09:00 - 14:00'));
      });

      test('should return "Cerrado" when closed', () {
        // Arrange
        const entity = ScheduleExceptionEntity(
          id: 'exc-1',
          scheduleId: 'sch-1',
          exceptionStartDate: '2026-12-25',
          exceptionEndDate: '2026-12-25',
          exceptionStartDateFormatted: '25 de Diciembre, 2026',
          dayName: 'Miércoles',
          openingTime: '00:00',
          closingTime: '00:00',
          isClosed: true,
          active: true,
        );

        // Assert
        expect(entity.displayTimeRange, equals('Cerrado'));
      });
    });

    group('isDateRange', () {
      test('should return true when start and end dates differ', () {
        // Arrange
        const entity = ScheduleExceptionEntity(
          id: 'exc-1',
          scheduleId: 'sch-1',
          exceptionStartDate: '2026-12-24',
          exceptionEndDate: '2026-12-31',
          exceptionStartDateFormatted: '24 de Diciembre, 2026',
          dayName: 'Martes',
          openingTime: '09:00',
          closingTime: '14:00',
          isClosed: false,
          active: true,
        );

        // Assert
        expect(entity.isDateRange, isTrue);
      });

      test('should return false when start and end dates are same', () {
        // Arrange
        const entity = ScheduleExceptionEntity(
          id: 'exc-1',
          scheduleId: 'sch-1',
          exceptionStartDate: '2026-12-24',
          exceptionEndDate: '2026-12-24',
          exceptionStartDateFormatted: '24 de Diciembre, 2026',
          dayName: 'Martes',
          openingTime: '09:00',
          closingTime: '14:00',
          isClosed: false,
          active: true,
        );

        // Assert
        expect(entity.isDateRange, isFalse);
      });
    });

    group('isPastDate', () {
      test('should return true for past date', () {
        // Arrange
        const entity = ScheduleExceptionEntity(
          id: 'exc-1',
          scheduleId: 'sch-1',
          exceptionStartDate: '2020-01-01',
          exceptionEndDate: '2020-01-01',
          exceptionStartDateFormatted: '1 de Enero, 2020',
          dayName: 'Miércoles',
          openingTime: '09:00',
          closingTime: '14:00',
          isClosed: false,
          active: true,
        );

        // Assert
        expect(entity.isPastDate, isTrue);
      });

      test('should return false for future date', () {
        // Arrange
        const entity = ScheduleExceptionEntity(
          id: 'exc-1',
          scheduleId: 'sch-1',
          exceptionStartDate: '2030-12-31',
          exceptionEndDate: '2030-12-31',
          exceptionStartDateFormatted: '31 de Diciembre, 2030',
          dayName: 'Martes',
          openingTime: '09:00',
          closingTime: '14:00',
          isClosed: false,
          active: true,
        );

        // Assert
        expect(entity.isPastDate, isFalse);
      });
    });

    group('copyWith', () {
      test('should copy with new active status', () {
        // Arrange
        const original = ScheduleExceptionEntity(
          id: 'exc-1',
          scheduleId: 'sch-1',
          exceptionStartDate: '2026-12-24',
          exceptionEndDate: '2026-12-24',
          exceptionStartDateFormatted: '24 de Diciembre, 2026',
          dayName: 'Martes',
          openingTime: '09:00',
          closingTime: '14:00',
          isClosed: false,
          active: true,
        );

        // Act
        final copied = original.copyWith(active: false);

        // Assert
        expect(copied.id, equals(original.id));
        expect(copied.exceptionStartDate, equals(original.exceptionStartDate));
        expect(copied.active, isFalse);
      });

      test('should return equivalent when no params provided', () {
        // Arrange
        const original = ScheduleExceptionEntity(
          id: 'exc-1',
          scheduleId: 'sch-1',
          exceptionStartDate: '2026-12-24',
          exceptionEndDate: '2026-12-24',
          exceptionStartDateFormatted: '24 de Diciembre, 2026',
          dayName: 'Martes',
          openingTime: '09:00',
          closingTime: '14:00',
          isClosed: false,
          active: true,
        );

        // Act
        final copied = original.copyWith();

        // Assert
        expect(copied, equals(original));
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        // Arrange
        const entity1 = ScheduleExceptionEntity(
          id: 'exc-1',
          scheduleId: 'sch-1',
          exceptionStartDate: '2026-12-24',
          exceptionEndDate: '2026-12-24',
          exceptionStartDateFormatted: '24 de Diciembre, 2026',
          dayName: 'Martes',
          openingTime: '09:00',
          closingTime: '14:00',
          isClosed: false,
          active: true,
        );
        const entity2 = ScheduleExceptionEntity(
          id: 'exc-1',
          scheduleId: 'sch-1',
          exceptionStartDate: '2026-12-24',
          exceptionEndDate: '2026-12-24',
          exceptionStartDateFormatted: '24 de Diciembre, 2026',
          dayName: 'Martes',
          openingTime: '09:00',
          closingTime: '14:00',
          isClosed: false,
          active: true,
        );

        // Assert
        expect(entity1, equals(entity2));
        expect(entity1.hashCode, equals(entity2.hashCode));
      });

      test('should not be equal when id differs', () {
        // Arrange
        const entity1 = ScheduleExceptionEntity(
          id: 'exc-1',
          scheduleId: 'sch-1',
          exceptionStartDate: '2026-12-24',
          exceptionEndDate: '2026-12-24',
          exceptionStartDateFormatted: '24 de Diciembre, 2026',
          dayName: 'Martes',
          openingTime: '09:00',
          closingTime: '14:00',
          isClosed: false,
          active: true,
        );
        const entity2 = ScheduleExceptionEntity(
          id: 'exc-2',
          scheduleId: 'sch-1',
          exceptionStartDate: '2026-12-24',
          exceptionEndDate: '2026-12-24',
          exceptionStartDateFormatted: '24 de Diciembre, 2026',
          dayName: 'Martes',
          openingTime: '09:00',
          closingTime: '14:00',
          isClosed: false,
          active: true,
        );

        // Assert
        expect(entity1, isNot(equals(entity2)));
      });
    });
  });
}
