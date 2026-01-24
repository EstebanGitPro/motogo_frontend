import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/branch_schedules/data/models/schedule_exception_model.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_exception_entity.dart';

void main() {
  group('ScheduleExceptionModel', () {
    group('fromJson', () {
      test('should create model from valid JSON', () {
        // Arrange
        final json = {
          'id': 'exception-123',
          'schedule_id': 'schedule-456',
          'exception_start_date': '2026-12-24',
          'exception_end_date': '2026-12-24',
          'exception_start_date_formatted': '24 de Diciembre, 2026',
          'day_name': 'Martes',
          'opening_time': '09:00',
          'closing_time': '14:00',
          'is_closed': false,
          'active': true,
        };

        // Act
        final model = ScheduleExceptionModel.fromJson(json);

        // Assert
        expect(model.id, equals('exception-123'));
        expect(model.scheduleId, equals('schedule-456'));
        expect(model.exceptionStartDate, equals('2026-12-24'));
        expect(model.exceptionEndDate, equals('2026-12-24'));
        expect(
          model.exceptionStartDateFormatted,
          equals('24 de Diciembre, 2026'),
        );
        expect(model.dayName, equals('Martes'));
        expect(model.openingTime, equals('09:00'));
        expect(model.closingTime, equals('14:00'));
        expect(model.isClosed, isFalse);
        expect(model.active, isTrue);
      });

      test('should create model with date range from JSON', () {
        // Arrange
        final json = {
          'id': 'exception-123',
          'schedule_id': 'schedule-456',
          'exception_start_date': '2026-12-24',
          'exception_end_date': '2026-12-31',
          'exception_start_date_formatted': '24 de Diciembre, 2026',
          'exception_end_date_formatted': '31 de Diciembre, 2026',
          'day_name': 'Martes',
          'opening_time': '09:00',
          'closing_time': '14:00',
          'is_closed': false,
          'active': true,
        };

        // Act
        final model = ScheduleExceptionModel.fromJson(json);

        // Assert
        expect(model.exceptionStartDate, equals('2026-12-24'));
        expect(model.exceptionEndDate, equals('2026-12-31'));
        expect(
          model.exceptionEndDateFormatted,
          equals('31 de Diciembre, 2026'),
        );
        expect(model.isDateRange, isTrue);
      });

      test('should handle null values with defaults', () {
        // Arrange
        final json = <String, dynamic>{};

        // Act
        final model = ScheduleExceptionModel.fromJson(json);

        // Assert
        expect(model.id, equals(''));
        expect(model.scheduleId, equals(''));
        expect(model.exceptionStartDate, equals(''));
        expect(model.exceptionEndDate, equals(''));
        expect(model.exceptionStartDateFormatted, equals(''));
        expect(model.exceptionEndDateFormatted, isNull);
        expect(model.dayName, equals(''));
        expect(model.openingTime, equals('00:00'));
        expect(model.closingTime, equals('00:00'));
        expect(model.isClosed, isFalse);
        expect(model.active, isTrue);
      });

      test('should parse closed exception correctly', () {
        // Arrange
        final json = {
          'id': 'exception-456',
          'schedule_id': 'schedule-789',
          'exception_start_date': '2026-12-25',
          'exception_end_date': '2026-12-25',
          'exception_start_date_formatted': '25 de Diciembre, 2026',
          'day_name': 'Miércoles',
          'opening_time': '00:00',
          'closing_time': '00:00',
          'is_closed': true,
          'active': true,
        };

        // Act
        final model = ScheduleExceptionModel.fromJson(json);

        // Assert
        expect(model.isClosed, isTrue);
        expect(model.displayTimeRange, equals('Cerrado'));
      });
    });

    group('toJson', () {
      test('should convert model to JSON for API requests (create)', () {
        // Arrange
        const model = ScheduleExceptionModel(
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

        // Act
        final json = model.toJson();

        // Assert
        expect(json['exception_start_date'], equals('2026-12-24'));
        expect(json['exception_end_date'], equals('2026-12-31'));
        expect(json['opening_time'], equals('09:00'));
        expect(json['closing_time'], equals('14:00'));
        expect(json['is_closed'], isFalse);
        // id and schedule_id should not be in toJson (server-managed)
        expect(json.containsKey('id'), isFalse);
        expect(json.containsKey('schedule_id'), isFalse);
      });

      test('should not include empty end date in toJson', () {
        // Arrange
        const model = ScheduleExceptionModel(
          id: 'exception-123',
          scheduleId: 'schedule-456',
          exceptionStartDate: '2026-12-24',
          exceptionEndDate: '',
          exceptionStartDateFormatted: '24 de Diciembre, 2026',
          dayName: 'Martes',
          openingTime: '09:00',
          closingTime: '14:00',
          isClosed: false,
          active: true,
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json.containsKey('exception_end_date'), isFalse);
      });
    });

    group('toUpdateJson', () {
      test('should only include time and is_closed for update', () {
        // Arrange
        const model = ScheduleExceptionModel(
          id: 'exception-123',
          scheduleId: 'schedule-456',
          exceptionStartDate: '2026-12-24',
          exceptionEndDate: '2026-12-31',
          exceptionStartDateFormatted: '24 de Diciembre, 2026',
          dayName: 'Martes',
          openingTime: '10:00',
          closingTime: '15:00',
          isClosed: false,
          active: true,
        );

        // Act
        final json = model.toUpdateJson();

        // Assert
        expect(json['opening_time'], equals('10:00'));
        expect(json['closing_time'], equals('15:00'));
        expect(json['is_closed'], isFalse);
        // Dates should not be in toUpdateJson
        expect(json.containsKey('exception_start_date'), isFalse);
        expect(json.containsKey('exception_end_date'), isFalse);
      });
    });

    group('toEntity', () {
      test('should convert model to entity', () {
        // Arrange
        const model = ScheduleExceptionModel(
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

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity, isA<ScheduleExceptionEntity>());
        expect(entity.id, equals(model.id));
        expect(entity.exceptionStartDate, equals(model.exceptionStartDate));
        expect(entity.openingTime, equals(model.openingTime));
        expect(entity.closingTime, equals(model.closingTime));
      });
    });

    group('fromEntity', () {
      test('should create model from entity', () {
        // Arrange
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

        // Act
        final model = ScheduleExceptionModel.fromEntity(entity);

        // Assert
        expect(model, isA<ScheduleExceptionModel>());
        expect(model.id, equals(entity.id));
        expect(model.exceptionStartDate, equals(entity.exceptionStartDate));
      });
    });
  });
}
