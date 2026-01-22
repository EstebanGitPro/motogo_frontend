import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/constants/schedule_constants.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/day_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_detail_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/presentation/widgets/time_slot_card.dart';

/// Expandable accordion tile for a day of the week.
///
/// Shows a summary when collapsed, and a list of time slots when expanded.
class DayAccordionTile extends StatelessWidget {
  final DayEntity day;
  final int dayNumber;
  final List<ScheduleDetailEntity> timeSlots;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final VoidCallback onAddTimeSlot;
  final void Function(ScheduleDetailEntity detail) onEditTimeSlot;
  final void Function(ScheduleDetailEntity detail) onDeleteTimeSlot;

  const DayAccordionTile({
    super.key,
    required this.day,
    required this.dayNumber,
    required this.timeSlots,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onAddTimeSlot,
    required this.onEditTimeSlot,
    required this.onDeleteTimeSlot,
  });

  /// Returns a summary string for the day when collapsed.
  String get _summary {
    if (timeSlots.isEmpty) {
      return ScheduleConstants.noTimeSlots;
    }

    // Check if any slot is marked as closed
    final closedSlots = timeSlots.where((s) => s.isClosed).toList();
    if (closedSlots.isNotEmpty) {
      return ScheduleConstants.closedForDay;
    }

    // Show first time range, or count if multiple
    if (timeSlots.length == 1) {
      return timeSlots.first.displayTimeRange;
    }

    // Multiple slots: show first and count
    final first = timeSlots.first;
    return '${first.displayTimeRange} (+${timeSlots.length - 1})';
  }

  bool get _isClosed {
    return timeSlots.any((s) => s.isClosed);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        children: [
          // Header (always visible)
          InkWell(
            onTap: onToggleExpand,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Expand/collapse icon
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    color: Colors.grey[600],
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  // Day name
                  Expanded(
                    child: Text(
                      day.label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _isClosed ? Colors.red[700] : Colors.grey[800],
                      ),
                    ),
                  ),
                  // Summary when collapsed
                  if (!isExpanded)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _isClosed
                            ? Colors.red[50]
                            : timeSlots.isEmpty
                            ? Colors.grey[100]
                            : const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _summary,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _isClosed
                              ? Colors.red[700]
                              : timeSlots.isEmpty
                              ? Colors.grey[500]
                              : const Color(0xFF10B981),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Expanded content
          if (isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(48, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Time slots list
                  if (timeSlots.isNotEmpty)
                    ...timeSlots.map(
                      (slot) => TimeSlotCard(
                        detail: slot,
                        onEdit: () => onEditTimeSlot(slot),
                        onDelete: () => onDeleteTimeSlot(slot),
                      ),
                    ),
                  // Add button
                  TextButton.icon(
                    onPressed: onAddTimeSlot,
                    icon: Icon(Icons.add, size: 18, color: Colors.blue[600]),
                    label: Text(
                      ScheduleConstants.addTimeSlot,
                      style: TextStyle(color: Colors.blue[600]),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: Colors.blue[200]!,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
