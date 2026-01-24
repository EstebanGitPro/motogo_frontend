import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/branch_schedules/data/models/schedule_detail_model.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_detail_entity.dart';

void main() {
  group('ScheduleDetailModel', () {
    group('fromJson', () {
      test('should create model from complete JSON', () {
        final json = {
          'id': 'detail-123',
          'schedule_id': 'schedule-456',
          'day_of_week': 1,
          'day_name': 'Lunes',
          'opening_time': '08:00',
          'closing_time': '18:00',
          'is_closed': false,
          'active': true,
        };

        final model = ScheduleDetailModel.fromJson(json);

        expect(model.id, 'detail-123');
        expect(model.scheduleId, 'schedule-456');
        expect(model.dayOfWeek, 1);
        expect(model.dayName, 'Lunes');
        expect(model.openingTime, '08:00');
        expect(model.closingTime, '18:00');
        expect(model.isClosed, false);
        expect(model.active, true);
      });

      test('should handle null values with defaults', () {
        final json = <String, dynamic>{};

        final model = ScheduleDetailModel.fromJson(json);

        expect(model.id, '');
        expect(model.scheduleId, '');
        expect(model.dayOfWeek, 1);
        expect(model.dayName, '');
        expect(model.openingTime, '00:00');
        expect(model.closingTime, '00:00');
        expect(model.isClosed, false);
        expect(model.active, true);
      });

      test('should parse closed day correctly', () {
        final json = {
          'id': 'detail-789',
          'schedule_id': 'schedule-456',
          'day_of_week': 7,
          'day_name': 'Domingo',
          'opening_time': '00:00',
          'closing_time': '00:00',
          'is_closed': true,
          'active': true,
        };

        final model = ScheduleDetailModel.fromJson(json);

        expect(model.isClosed, true);
        expect(model.dayOfWeek, 7);
        expect(model.dayName, 'Domingo');
      });
    });

    group('toJson', () {
      test('should serialize to JSON for API request', () {
        const model = ScheduleDetailModel(
          id: 'detail-123',
          scheduleId: 'schedule-456',
          dayOfWeek: 2,
          dayName: 'Martes',
          openingTime: '09:00',
          closingTime: '17:00',
          isClosed: false,
          active: true,
        );

        final json = model.toJson();

        // toJson only includes fields needed for API request
        expect(json['day_of_week'], 2);
        expect(json['opening_time'], '09:00');
        expect(json['closing_time'], '17:00');
        expect(json['is_closed'], false);
        // These should NOT be in toJson for create/update
        expect(json.containsKey('id'), false);
        expect(json.containsKey('schedule_id'), false);
        expect(json.containsKey('day_name'), false);
        expect(json.containsKey('active'), false);
      });
    });

    group('fromEntity', () {
      test('should create model from ScheduleDetailEntity', () {
        const entity = ScheduleDetailEntity(
          id: 'entity-id',
          scheduleId: 'schedule-id',
          dayOfWeek: 3,
          dayName: 'Miércoles',
          openingTime: '07:30',
          closingTime: '19:30',
          isClosed: false,
          active: true,
        );

        final model = ScheduleDetailModel.fromEntity(entity);

        expect(model.id, 'entity-id');
        expect(model.scheduleId, 'schedule-id');
        expect(model.dayOfWeek, 3);
        expect(model.dayName, 'Miércoles');
        expect(model.openingTime, '07:30');
        expect(model.closingTime, '19:30');
        expect(model.isClosed, false);
        expect(model.active, true);
      });
    });

    group('toEntity', () {
      test('should convert to ScheduleDetailEntity', () {
        const model = ScheduleDetailModel(
          id: 'model-id',
          scheduleId: 'sched-id',
          dayOfWeek: 5,
          dayName: 'Viernes',
          openingTime: '10:00',
          closingTime: '20:00',
          isClosed: false,
          active: true,
        );

        final entity = model.toEntity();

        expect(entity, isA<ScheduleDetailEntity>());
        expect(entity.id, 'model-id');
        expect(entity.scheduleId, 'sched-id');
        expect(entity.dayOfWeek, 5);
        expect(entity.dayName, 'Viernes');
        expect(entity.openingTime, '10:00');
        expect(entity.closingTime, '20:00');
        expect(entity.isClosed, false);
        expect(entity.active, true);
      });
    });

    group('inheritance', () {
      test('should extend ScheduleDetailEntity', () {
        const model = ScheduleDetailModel(
          id: 'id',
          scheduleId: 'sid',
          dayOfWeek: 1,
          dayName: 'Lunes',
          openingTime: '08:00',
          closingTime: '18:00',
          isClosed: false,
          active: true,
        );

        expect(model, isA<ScheduleDetailEntity>());
      });
    });
  });
}
