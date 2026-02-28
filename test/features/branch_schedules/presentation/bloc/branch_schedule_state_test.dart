import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/day_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_detail_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_exception_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/presentation/bloc/branch_schedule_state.dart';

void main() {
  group('LoadingSection', () {
    test('enum values exist', () {
      expect(LoadingSection.values.length, 3);
      expect(LoadingSection.none, isNotNull);
      expect(LoadingSection.details, isNotNull);
      expect(LoadingSection.exceptions, isNotNull);
    });
  });

  group('BranchScheduleState', () {
    group('BranchScheduleInitial', () {
      test('creates initial state', () {
        final state = BranchScheduleInitial();
        expect(state, isA<BranchScheduleState>());
      });

      test('props is empty', () {
        final state = BranchScheduleInitial();
        expect(state.props, isEmpty);
      });
    });

    group('BranchScheduleLoading', () {
      test('creates loading state', () {
        final state = BranchScheduleLoading();
        expect(state, isA<BranchScheduleState>());
      });
    });

    group('BranchScheduleLoaded', () {
      final testSchedule = ScheduleEntity(
        id: 'schedule-1',
        branchId: 'branch-1',
        active: true,
      );

      final testDays = [
        const DayEntity(value: 'monday', label: 'Lunes'),
        const DayEntity(value: 'tuesday', label: 'Martes'),
      ];

      final testDetails = [
        const ScheduleDetailEntity(
          id: 'detail-1',
          scheduleId: 'schedule-1',
          dayOfWeek: 1,
          dayName: 'Lunes',
          openingTime: '08:00',
          closingTime: '18:00',
          isClosed: false,
          active: true,
        ),
        const ScheduleDetailEntity(
          id: 'detail-2',
          scheduleId: 'schedule-1',
          dayOfWeek: 1,
          dayName: 'Lunes',
          openingTime: '19:00',
          closingTime: '22:00',
          isClosed: false,
          active: true,
        ),
        const ScheduleDetailEntity(
          id: 'detail-3',
          scheduleId: 'schedule-1',
          dayOfWeek: 2,
          dayName: 'Martes',
          openingTime: '09:00',
          closingTime: '17:00',
          isClosed: false,
          active: true,
        ),
      ];

      final testExceptions = [
        const ScheduleExceptionEntity(
          id: 'exc-1',
          scheduleId: 'schedule-1',
          exceptionStartDate: '2026-03-15',
          exceptionEndDate: '2026-03-15',
          exceptionStartDateFormatted: '15 de Marzo, 2026',
          dayName: 'Domingo',
          openingTime: '10:00',
          closingTime: '14:00',
          isClosed: false,
          active: true,
        ),
        const ScheduleExceptionEntity(
          id: 'exc-2',
          scheduleId: 'schedule-1',
          exceptionStartDate: '2026-03-01',
          exceptionEndDate: '2026-03-01',
          exceptionStartDateFormatted: '01 de Marzo, 2026',
          dayName: 'Domingo',
          openingTime: '00:00',
          closingTime: '00:00',
          isClosed: true,
          active: true,
        ),
      ];

      test('creates loaded state with required schedule', () {
        final state = BranchScheduleLoaded(schedule: testSchedule);

        expect(state.schedule, testSchedule);
        expect(state.daysCatalog, isEmpty);
        expect(state.details, isEmpty);
        expect(state.exceptions, isEmpty);
        expect(state.message, isNull);
        expect(state.isSuccess, true);
        expect(state.loadingSection, LoadingSection.none);
      });

      test('creates loaded state with all fields', () {
        final state = BranchScheduleLoaded(
          schedule: testSchedule,
          daysCatalog: testDays,
          details: testDetails,
          exceptions: testExceptions,
          message: 'Horario actualizado',
          isSuccess: true,
          loadingSection: LoadingSection.details,
        );

        expect(state.daysCatalog.length, 2);
        expect(state.details.length, 3);
        expect(state.exceptions.length, 2);
        expect(state.message, 'Horario actualizado');
        expect(state.loadingSection, LoadingSection.details);
      });

      test('isDetailsLoading returns true when loading details', () {
        final state = BranchScheduleLoaded(
          schedule: testSchedule,
          loadingSection: LoadingSection.details,
        );
        expect(state.isDetailsLoading, true);
        expect(state.isExceptionsLoading, false);
      });

      test('isExceptionsLoading returns true when loading exceptions', () {
        final state = BranchScheduleLoaded(
          schedule: testSchedule,
          loadingSection: LoadingSection.exceptions,
        );
        expect(state.isDetailsLoading, false);
        expect(state.isExceptionsLoading, true);
      });

      test('detailsByDay groups details by dayOfWeek', () {
        final state = BranchScheduleLoaded(
          schedule: testSchedule,
          details: testDetails,
        );

        final grouped = state.detailsByDay;
        expect(grouped.keys.length, 2);
        expect(grouped[1]!.length, 2);
        expect(grouped[2]!.length, 1);
      });

      test('detailsByDay sorts by opening time', () {
        final state = BranchScheduleLoaded(
          schedule: testSchedule,
          details: testDetails,
        );

        final day1Details = state.detailsByDay[1]!;
        expect(day1Details.first.openingTime, '08:00');
        expect(day1Details.last.openingTime, '19:00');
      });

      test('sortedExceptions returns sorted by date', () {
        final state = BranchScheduleLoaded(
          schedule: testSchedule,
          exceptions: testExceptions,
        );

        final sorted = state.sortedExceptions;
        expect(sorted.first.exceptionStartDate, '2026-03-01');
        expect(sorted.last.exceptionStartDate, '2026-03-15');
      });

      test('copyWith creates new state with updated values', () {
        final state = BranchScheduleLoaded(
          schedule: testSchedule,
          daysCatalog: testDays,
          details: testDetails,
          message: 'Old message',
        );

        final newState = state.copyWith(
          message: 'New message',
          isSuccess: false,
          loadingSection: LoadingSection.exceptions,
        );

        expect(newState.message, 'New message');
        expect(newState.isSuccess, false);
        expect(newState.loadingSection, LoadingSection.exceptions);
        expect(newState.schedule, testSchedule);
        expect(newState.details, testDetails);
      });

      test('copyWith resets message to null when not provided', () {
        final state = BranchScheduleLoaded(
          schedule: testSchedule,
          message: 'Some message',
        );

        final newState = state.copyWith(isSuccess: true);
        expect(newState.message, isNull);
      });

      test('copyWith resets loadingSection to none when not provided', () {
        final state = BranchScheduleLoaded(
          schedule: testSchedule,
          loadingSection: LoadingSection.details,
        );

        final newState = state.copyWith();
        expect(newState.loadingSection, LoadingSection.none);
      });

      test('supports equality', () {
        final state1 = BranchScheduleLoaded(schedule: testSchedule);
        final state2 = BranchScheduleLoaded(schedule: testSchedule);
        expect(state1, equals(state2));
      });

      test('props contains all fields', () {
        final state = BranchScheduleLoaded(
          schedule: testSchedule,
          daysCatalog: testDays,
          details: testDetails,
          exceptions: testExceptions,
          message: 'msg',
          isSuccess: true,
          loadingSection: LoadingSection.details,
        );
        expect(state.props.length, 7);
      });
    });

    group('BranchScheduleNotFound', () {
      test('creates state with defaults', () {
        const state = BranchScheduleNotFound();
        expect(state.daysCatalog, isEmpty);
        expect(state.message, isNull);
        expect(state.isSuccess, true);
      });

      test('creates state with all fields', () {
        final days = [const DayEntity(value: 'monday', label: 'Lunes')];
        final state = BranchScheduleNotFound(
          daysCatalog: days,
          message: 'No schedule',
          isSuccess: false,
        );
        expect(state.daysCatalog.length, 1);
        expect(state.message, 'No schedule');
        expect(state.isSuccess, false);
      });

      test('supports equality', () {
        const state1 = BranchScheduleNotFound();
        const state2 = BranchScheduleNotFound();
        expect(state1, equals(state2));
      });

      test('props contains all fields', () {
        const state = BranchScheduleNotFound(message: 'msg', isSuccess: true);
        expect(state.props.length, 3);
      });
    });

    group('BranchScheduleError', () {
      test('creates error state with message', () {
        const state = BranchScheduleError('Error de conexión');
        expect(state.message, 'Error de conexión');
      });

      test('supports equality', () {
        const state1 = BranchScheduleError('Error');
        const state2 = BranchScheduleError('Error');
        const state3 = BranchScheduleError('Otro error');
        expect(state1, equals(state2));
        expect(state1, isNot(equals(state3)));
      });

      test('props contains message', () {
        const state = BranchScheduleError('Error');
        expect(state.props, ['Error']);
      });
    });

    group('BranchScheduleOperating', () {
      test('creates operating state with operation name', () {
        const state = BranchScheduleOperating('create');
        expect(state.operation, 'create');
      });

      test('supports equality', () {
        const state1 = BranchScheduleOperating('delete');
        const state2 = BranchScheduleOperating('delete');
        const state3 = BranchScheduleOperating('toggle');
        expect(state1, equals(state2));
        expect(state1, isNot(equals(state3)));
      });

      test('props contains operation', () {
        const state = BranchScheduleOperating('create');
        expect(state.props, ['create']);
      });
    });
  });
}
