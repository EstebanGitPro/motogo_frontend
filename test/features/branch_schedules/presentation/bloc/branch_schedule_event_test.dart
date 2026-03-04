import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/branch_schedules/presentation/bloc/branch_schedule_event.dart';

void main() {
  group('BranchScheduleEvent', () {
    group('LoadSchedule', () {
      test('creates event with branchId', () {
        const event = LoadSchedule('branch-123');
        expect(event.branchId, 'branch-123');
      });

      test('supports equality', () {
        const event1 = LoadSchedule('branch-123');
        const event2 = LoadSchedule('branch-123');
        const event3 = LoadSchedule('branch-456');

        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });

      test('props contains branchId', () {
        const event = LoadSchedule('branch-123');
        expect(event.props, ['branch-123']);
      });
    });

    group('CreateSchedule', () {
      test('creates event with branchId', () {
        const event = CreateSchedule('branch-123');
        expect(event.branchId, 'branch-123');
      });

      test('supports equality', () {
        const event1 = CreateSchedule('branch-123');
        const event2 = CreateSchedule('branch-123');
        expect(event1, equals(event2));
      });
    });

    group('DeleteSchedule', () {
      test('creates event with branchId', () {
        const event = DeleteSchedule('branch-123');
        expect(event.branchId, 'branch-123');
      });

      test('supports equality', () {
        const event1 = DeleteSchedule('branch-123');
        const event2 = DeleteSchedule('branch-123');
        expect(event1, equals(event2));
      });
    });

    group('ToggleScheduleStatus', () {
      test('creates event with branchId and activate', () {
        const event = ToggleScheduleStatus(
          branchId: 'branch-123',
          activate: true,
        );
        expect(event.branchId, 'branch-123');
        expect(event.activate, true);
      });

      test('supports equality', () {
        const event1 = ToggleScheduleStatus(
          branchId: 'branch-123',
          activate: true,
        );
        const event2 = ToggleScheduleStatus(
          branchId: 'branch-123',
          activate: true,
        );
        const event3 = ToggleScheduleStatus(
          branchId: 'branch-123',
          activate: false,
        );
        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });

      test('props contains branchId and activate', () {
        const event = ToggleScheduleStatus(
          branchId: 'branch-123',
          activate: true,
        );
        expect(event.props, ['branch-123', true]);
      });
    });

    group('UpdateSchedule', () {
      test('creates event with all fields', () {
        final startDate = DateTime(2026, 1, 1);
        final endDate = DateTime(2026, 12, 31);
        final event = UpdateSchedule(
          branchId: 'branch-123',
          active: true,
          startDate: startDate,
          endDate: endDate,
        );
        expect(event.branchId, 'branch-123');
        expect(event.active, true);
        expect(event.startDate, startDate);
        expect(event.endDate, endDate);
      });

      test('creates event with optional fields as null', () {
        const event = UpdateSchedule(branchId: 'branch-123');
        expect(event.active, isNull);
        expect(event.startDate, isNull);
        expect(event.endDate, isNull);
      });

      test('supports equality', () {
        final date = DateTime(2026, 1, 1);
        final event1 = UpdateSchedule(branchId: 'branch-123', startDate: date);
        final event2 = UpdateSchedule(branchId: 'branch-123', startDate: date);
        expect(event1, equals(event2));
      });
    });

    group('ClearMessage', () {
      test('creates event', () {
        final event = ClearMessage();
        expect(event, isA<BranchScheduleEvent>());
      });

      test('props is empty', () {
        final event = ClearMessage();
        expect(event.props, isEmpty);
      });
    });

    group('LoadScheduleDetails', () {
      test('creates event with branchId', () {
        const event = LoadScheduleDetails('branch-123');
        expect(event.branchId, 'branch-123');
      });

      test('supports equality', () {
        const event1 = LoadScheduleDetails('branch-123');
        const event2 = LoadScheduleDetails('branch-123');
        expect(event1, equals(event2));
      });
    });

    group('CreateScheduleDetail', () {
      test('creates event with all required fields', () {
        const event = CreateScheduleDetail(
          branchId: 'branch-123',
          dayOfWeek: 1,
          openingTime: '08:00',
          closingTime: '18:00',
        );
        expect(event.branchId, 'branch-123');
        expect(event.dayOfWeek, 1);
        expect(event.openingTime, '08:00');
        expect(event.closingTime, '18:00');
        expect(event.isClosed, false);
      });

      test('creates event with isClosed true', () {
        const event = CreateScheduleDetail(
          branchId: 'branch-123',
          dayOfWeek: 7,
          openingTime: '00:00',
          closingTime: '00:00',
          isClosed: true,
        );
        expect(event.isClosed, true);
      });

      test('supports equality', () {
        const event1 = CreateScheduleDetail(
          branchId: 'b',
          dayOfWeek: 1,
          openingTime: '08:00',
          closingTime: '18:00',
        );
        const event2 = CreateScheduleDetail(
          branchId: 'b',
          dayOfWeek: 1,
          openingTime: '08:00',
          closingTime: '18:00',
        );
        expect(event1, equals(event2));
      });

      test('props contains all fields', () {
        const event = CreateScheduleDetail(
          branchId: 'b',
          dayOfWeek: 1,
          openingTime: '08:00',
          closingTime: '18:00',
          isClosed: false,
        );
        expect(event.props, ['b', 1, '08:00', '18:00', false]);
      });
    });

    group('UpdateScheduleDetail', () {
      test('creates event with all required fields', () {
        const event = UpdateScheduleDetail(
          branchId: 'branch-123',
          detailId: 'detail-456',
          openingTime: '09:00',
          closingTime: '17:00',
        );
        expect(event.branchId, 'branch-123');
        expect(event.detailId, 'detail-456');
        expect(event.openingTime, '09:00');
        expect(event.closingTime, '17:00');
        expect(event.isClosed, false);
      });

      test('supports equality', () {
        const event1 = UpdateScheduleDetail(
          branchId: 'b',
          detailId: 'd',
          openingTime: '09:00',
          closingTime: '17:00',
        );
        const event2 = UpdateScheduleDetail(
          branchId: 'b',
          detailId: 'd',
          openingTime: '09:00',
          closingTime: '17:00',
        );
        expect(event1, equals(event2));
      });
    });

    group('DeleteScheduleDetail', () {
      test('creates event with branchId and detailId', () {
        const event = DeleteScheduleDetail(
          branchId: 'branch-123',
          detailId: 'detail-456',
        );
        expect(event.branchId, 'branch-123');
        expect(event.detailId, 'detail-456');
      });

      test('supports equality', () {
        const event1 = DeleteScheduleDetail(branchId: 'b', detailId: 'd');
        const event2 = DeleteScheduleDetail(branchId: 'b', detailId: 'd');
        expect(event1, equals(event2));
      });
    });

    group('LoadScheduleExceptions', () {
      test('creates event with branchId', () {
        const event = LoadScheduleExceptions('branch-123');
        expect(event.branchId, 'branch-123');
      });

      test('supports equality', () {
        const event1 = LoadScheduleExceptions('branch-123');
        const event2 = LoadScheduleExceptions('branch-123');
        expect(event1, equals(event2));
      });
    });

    group('CreateScheduleException', () {
      test('creates event with all required fields', () {
        const event = CreateScheduleException(
          branchId: 'branch-123',
          exceptionStartDate: '2026-03-01',
          openingTime: '10:00',
          closingTime: '14:00',
        );
        expect(event.branchId, 'branch-123');
        expect(event.exceptionStartDate, '2026-03-01');
        expect(event.exceptionEndDate, isNull);
        expect(event.openingTime, '10:00');
        expect(event.closingTime, '14:00');
        expect(event.isClosed, false);
      });

      test('creates event with optional endDate and isClosed', () {
        const event = CreateScheduleException(
          branchId: 'branch-123',
          exceptionStartDate: '2026-03-01',
          exceptionEndDate: '2026-03-05',
          openingTime: '00:00',
          closingTime: '00:00',
          isClosed: true,
        );
        expect(event.exceptionEndDate, '2026-03-05');
        expect(event.isClosed, true);
      });

      test('supports equality', () {
        const event1 = CreateScheduleException(
          branchId: 'b',
          exceptionStartDate: '2026-03-01',
          openingTime: '10:00',
          closingTime: '14:00',
        );
        const event2 = CreateScheduleException(
          branchId: 'b',
          exceptionStartDate: '2026-03-01',
          openingTime: '10:00',
          closingTime: '14:00',
        );
        expect(event1, equals(event2));
      });

      test('props contains all fields', () {
        const event = CreateScheduleException(
          branchId: 'b',
          exceptionStartDate: '2026-03-01',
          exceptionEndDate: '2026-03-05',
          openingTime: '10:00',
          closingTime: '14:00',
          isClosed: true,
        );
        expect(event.props, [
          'b',
          '2026-03-01',
          '2026-03-05',
          '10:00',
          '14:00',
          true,
        ]);
      });
    });

    group('UpdateScheduleException', () {
      test('creates event with all required fields', () {
        const event = UpdateScheduleException(
          branchId: 'branch-123',
          exceptionId: 'exc-456',
          openingTime: '10:00',
          closingTime: '14:00',
        );
        expect(event.branchId, 'branch-123');
        expect(event.exceptionId, 'exc-456');
        expect(event.openingTime, '10:00');
        expect(event.closingTime, '14:00');
        expect(event.isClosed, false);
      });

      test('supports equality', () {
        const event1 = UpdateScheduleException(
          branchId: 'b',
          exceptionId: 'e',
          openingTime: '10:00',
          closingTime: '14:00',
        );
        const event2 = UpdateScheduleException(
          branchId: 'b',
          exceptionId: 'e',
          openingTime: '10:00',
          closingTime: '14:00',
        );
        expect(event1, equals(event2));
      });
    });

    group('DeleteScheduleException', () {
      test('creates event with branchId and exceptionId', () {
        const event = DeleteScheduleException(
          branchId: 'branch-123',
          exceptionId: 'exc-456',
        );
        expect(event.branchId, 'branch-123');
        expect(event.exceptionId, 'exc-456');
      });

      test('supports equality', () {
        const event1 = DeleteScheduleException(branchId: 'b', exceptionId: 'e');
        const event2 = DeleteScheduleException(branchId: 'b', exceptionId: 'e');
        expect(event1, equals(event2));
      });
    });

    group('ToggleScheduleExceptionStatus', () {
      test('creates event with all fields', () {
        const event = ToggleScheduleExceptionStatus(
          branchId: 'branch-123',
          exceptionId: 'exc-456',
          activate: true,
        );
        expect(event.branchId, 'branch-123');
        expect(event.exceptionId, 'exc-456');
        expect(event.activate, true);
      });

      test('supports equality', () {
        const event1 = ToggleScheduleExceptionStatus(
          branchId: 'b',
          exceptionId: 'e',
          activate: true,
        );
        const event2 = ToggleScheduleExceptionStatus(
          branchId: 'b',
          exceptionId: 'e',
          activate: true,
        );
        const event3 = ToggleScheduleExceptionStatus(
          branchId: 'b',
          exceptionId: 'e',
          activate: false,
        );
        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });

      test('props contains all fields', () {
        const event = ToggleScheduleExceptionStatus(
          branchId: 'b',
          exceptionId: 'e',
          activate: true,
        );
        expect(event.props, ['b', 'e', true]);
      });
    });
  });
}
