import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/constants/schedule_constants.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_detail_entity.dart';

/// Card widget for displaying a single time slot with edit/delete actions.
class TimeSlotCard extends StatelessWidget {
  final ScheduleDetailEntity detail;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TimeSlotCard({
    super.key,
    required this.detail,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: detail.isClosed ? Colors.red[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: detail.isClosed ? Colors.red[200]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          // Time icon
          Icon(
            detail.isClosed ? Icons.block : Icons.schedule,
            size: 18,
            color: detail.isClosed ? Colors.red[400] : Colors.grey[600],
          ),
          const SizedBox(width: 10),
          // Time range or closed label
          Expanded(
            child: Text(
              detail.isClosed
                  ? ScheduleConstants.closedForDay
                  : '${detail.openingTime} - ${detail.closingTime}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: detail.isClosed ? Colors.red[700] : Colors.grey[800],
              ),
            ),
          ),
          // Edit button
          IconButton(
            onPressed: onEdit,
            icon: Icon(Icons.edit_outlined, size: 18, color: Colors.blue[600]),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            tooltip: ScheduleConstants.editTimeSlot,
          ),
          // Delete button
          IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline, size: 18, color: Colors.red[400]),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            tooltip: ScheduleConstants.deleteTimeSlot,
          ),
        ],
      ),
    );
  }
}
