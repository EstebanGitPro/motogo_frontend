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
    final grouped = _groupSchedulesByDay();
    final sortedDays = grouped.keys.toList()..sort();
    final now = DateTime.now();
    final hasTodayException = _hasTodayClosedException(now);

    return sortedDays.map((day) {
      final schedule = grouped[day]!;
      final isToday = day == now.weekday;
      final showException = isToday && hasTodayException;

      return _buildScheduleRow(schedule, isToday, showException);
    }).toList();
  }

  /// Groups schedules by day of week, keeping only the first per day.
  Map<int, ScheduleDetailEntity> _groupSchedulesByDay() {
    final grouped = <int, ScheduleDetailEntity>{};
    for (final schedule in schedules) {
      if (!grouped.containsKey(schedule.dayOfWeek)) {
        grouped[schedule.dayOfWeek] = schedule;
      }
    }
    return grouped;
  }

  /// Checks whether today falls within an active closed exception.
  bool _hasTodayClosedException(DateTime now) {
    final todayOnly = DateTime(now.year, now.month, now.day);

    return exceptions.any((e) {
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
  }

  /// Resolves the display text for a schedule row.
  String _scheduleText(ScheduleDetailEntity schedule, bool showException) {
    if (showException) return BranchDetailConstants.statusClosedException;
    if (schedule.isClosed) return BranchDetailConstants.dayClosed;
    return '${schedule.openingTime} - ${schedule.closingTime}';
  }

  /// Resolves the text color for a schedule row.
  Color _scheduleColor(ScheduleDetailEntity schedule, bool showException) {
    if (showException) return Colors.orange[700]!;
    if (schedule.isClosed) return Colors.grey;
    return Colors.black87;
  }

  /// Builds a single schedule row widget.
  Widget _buildScheduleRow(
    ScheduleDetailEntity schedule,
    bool isToday,
    bool showException,
  ) {
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
              _scheduleText(schedule, showException),
              style: TextStyle(
                color: _scheduleColor(schedule, showException),
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
