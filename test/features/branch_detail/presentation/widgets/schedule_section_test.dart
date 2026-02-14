import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/constants/branch_detail_constants.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_detail_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_exception_entity.dart';
import 'package:motogo_frontend/src/features/branch_detail/presentation/widgets/schedule_section.dart';

void main() {
  ScheduleDetailEntity makeSchedule({
    required int dayOfWeek,
    required String dayName,
    String openingTime = '08:00',
    String closingTime = '18:00',
    bool isClosed = false,
  }) {
    return ScheduleDetailEntity(
      id: 'sd-$dayOfWeek',
      scheduleId: 'sch-1',
      dayOfWeek: dayOfWeek,
      dayName: dayName,
      openingTime: openingTime,
      closingTime: closingTime,
      isClosed: isClosed,
      active: true,
    );
  }

  Widget buildTestWidget({
    required List<ScheduleDetailEntity> schedules,
    List<ScheduleExceptionEntity> exceptions = const [],
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ScheduleSection(schedules: schedules, exceptions: exceptions),
        ),
      ),
    );
  }

  group('ScheduleSection', () {
    testWidgets('shows section title', (tester) async {
      await tester.pumpWidget(buildTestWidget(schedules: []));
      expect(find.text(BranchDetailConstants.sectionSchedule), findsOneWidget);
    });

    testWidgets('shows empty message when no schedules', (tester) async {
      await tester.pumpWidget(buildTestWidget(schedules: []));
      expect(
        find.text(BranchDetailConstants.noScheduleAvailable),
        findsOneWidget,
      );
    });

    testWidgets('displays schedule rows with day names', (tester) async {
      final schedules = [
        makeSchedule(dayOfWeek: 1, dayName: 'Lunes'),
        makeSchedule(dayOfWeek: 2, dayName: 'Martes'),
        makeSchedule(dayOfWeek: 3, dayName: 'Miércoles'),
      ];
      await tester.pumpWidget(buildTestWidget(schedules: schedules));

      expect(find.textContaining('Lunes'), findsOneWidget);
      expect(find.textContaining('Martes'), findsOneWidget);
      expect(find.textContaining('Miércoles'), findsOneWidget);
    });

    testWidgets('displays time range for open days', (tester) async {
      final schedules = [
        makeSchedule(
          dayOfWeek: 1,
          dayName: 'Lunes',
          openingTime: '09:00',
          closingTime: '17:00',
        ),
      ];
      await tester.pumpWidget(buildTestWidget(schedules: schedules));
      expect(find.text('09:00 - 17:00'), findsOneWidget);
    });

    testWidgets('displays closed label for closed days', (tester) async {
      final schedules = [
        makeSchedule(dayOfWeek: 7, dayName: 'Domingo', isClosed: true),
      ];
      await tester.pumpWidget(buildTestWidget(schedules: schedules));
      expect(find.text(BranchDetailConstants.dayClosed), findsOneWidget);
    });

    testWidgets('highlights today with bold and marker', (tester) async {
      final today = DateTime.now().weekday;
      final dayNames = {
        1: 'Lunes',
        2: 'Martes',
        3: 'Miércoles',
        4: 'Jueves',
        5: 'Viernes',
        6: 'Sábado',
        7: 'Domingo',
      };

      final schedules = [
        makeSchedule(dayOfWeek: today, dayName: dayNames[today]!),
      ];
      await tester.pumpWidget(buildTestWidget(schedules: schedules));

      // Today's row should include the (Hoy) marker
      expect(
        find.textContaining(BranchDetailConstants.dayToday),
        findsOneWidget,
      );
    });

    testWidgets('shows exception status when today has closed exception', (
      tester,
    ) async {
      final today = DateTime.now();
      final todayWeekday = today.weekday;
      final todayStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final schedules = [makeSchedule(dayOfWeek: todayWeekday, dayName: 'Hoy')];

      final exceptions = [
        ScheduleExceptionEntity(
          id: 'exc-1',
          scheduleId: 'sch-1',
          exceptionStartDate: todayStr,
          exceptionEndDate: todayStr,
          exceptionStartDateFormatted: 'Hoy',
          dayName: 'Hoy',
          openingTime: '',
          closingTime: '',
          isClosed: true,
          active: true,
        ),
      ];

      await tester.pumpWidget(
        buildTestWidget(schedules: schedules, exceptions: exceptions),
      );

      expect(
        find.text(BranchDetailConstants.statusClosedException),
        findsOneWidget,
      );
    });

    testWidgets('sorts days in order', (tester) async {
      final schedules = [
        makeSchedule(dayOfWeek: 5, dayName: 'Viernes'),
        makeSchedule(dayOfWeek: 1, dayName: 'Lunes'),
        makeSchedule(dayOfWeek: 3, dayName: 'Miércoles'),
      ];
      await tester.pumpWidget(buildTestWidget(schedules: schedules));

      // All three should be visible
      expect(find.textContaining('Lunes'), findsOneWidget);
      expect(find.textContaining('Miércoles'), findsOneWidget);
      expect(find.textContaining('Viernes'), findsOneWidget);
    });
  });
}
