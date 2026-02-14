import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/constants/branch_detail_constants.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_detail_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_exception_entity.dart';

/// Section widget displaying the weekly schedule of a branch.
///
/// Shows a titled card with schedule rows grouped by day of week,
/// highlighting today's entry and showing active exceptions.
class ScheduleSection extends StatelessWidget {
  final List<ScheduleDetailEntity> schedules;
  final List<ScheduleExceptionEntity> exceptions;

  const ScheduleSection({
    super.key,
    required this.schedules,
    required this.exceptions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            BranchDetailConstants.sectionSchedule,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: schedules.isEmpty
                ? Text(
                    BranchDetailConstants.noScheduleAvailable,
                    style: TextStyle(color: Colors.grey[600]),
                  )
                : Column(children: _buildScheduleRows()),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildScheduleRows() {
    // Group by day and sort
    final grouped = <int, ScheduleDetailEntity>{};
    for (final schedule in schedules) {
      if (!grouped.containsKey(schedule.dayOfWeek)) {
        grouped[schedule.dayOfWeek] = schedule;
      }
    }

    final sortedDays = grouped.keys.toList()..sort();
    final now = DateTime.now();
    final todayOnly = DateTime(now.year, now.month, now.day);

    // Check if today has an active closed exception
    final hasTodayException = exceptions.any((e) {
      if (!e.active || !e.isClosed) return false;
      final startDate = DateTime.tryParse(e.exceptionStartDate);
      final endDate = DateTime.tryParse(e.exceptionEndDate);
      if (startDate == null || endDate == null) return false;
      final startOnly = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );
      final endOnly = DateTime(endDate.year, endDate.month, endDate.day);
      return !todayOnly.isBefore(startOnly) && !todayOnly.isAfter(endOnly);
    });

    return sortedDays.map((day) {
      final schedule = grouped[day]!;
      final isToday = day == now.weekday;
      final showException = isToday && hasTodayException;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              child: Text(
                schedule.dayName +
                    (isToday ? ' ${BranchDetailConstants.dayToday}' : ''),
                style: TextStyle(
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isToday ? Colors.blue[700] : Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                showException
                    ? BranchDetailConstants.statusClosedException
                    : schedule.isClosed
                    ? BranchDetailConstants.dayClosed
                    : '${schedule.openingTime} - ${schedule.closingTime}',
                style: TextStyle(
                  color: showException
                      ? Colors.orange[700]
                      : schedule.isClosed
                      ? Colors.grey
                      : Colors.black87,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
