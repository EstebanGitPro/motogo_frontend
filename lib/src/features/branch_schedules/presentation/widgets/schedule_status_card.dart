import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motogo_frontend/src/core/constants/schedule_constants.dart';

/// Card widget displaying schedule status with toggle and delete options.
///
/// Note: The days accordion is now managed by the parent widget.
class ScheduleStatusCard extends StatelessWidget {
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;
  final VoidCallback? onEditValidity;

  const ScheduleStatusCard({
    super.key,
    required this.isActive,
    this.startDate,
    this.endDate,
    required this.onToggle,
    required this.onDelete,
    this.onEditValidity,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return ScheduleConstants.validityIndefinite;
    return DateFormat('dd MMM yyyy', 'es').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF10B981).withValues(alpha: 0.1)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.schedule,
                    color: isActive
                        ? const Color(0xFF10B981)
                        : Colors.grey[400],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        ScheduleConstants.schedulesTitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFF10B981)
                                  : Colors.grey[400],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isActive
                                  ? ScheduleConstants.statusActive
                                  : ScheduleConstants.statusInactive,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Toggle switch
                Switch(
                  value: isActive,
                  onChanged: onToggle,
                  activeTrackColor: const Color(
                    0xFF10B981,
                  ).withValues(alpha: 0.5),
                  activeThumbColor: const Color(0xFF10B981),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            // Validity period section
            if (startDate != null) ...[
              _buildValiditySection(context),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
            ],
            // Actions row
            // Actions row with visibility info and delete
            Row(
              children: [
                Expanded(
                  child: Text(
                    isActive
                        ? ScheduleConstants.scheduleVisibleMessage
                        : ScheduleConstants.scheduleNotVisibleMessage,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red[400],
                    size: 20,
                  ),
                  label: Text(
                    ScheduleConstants.deleteSchedule,
                    style: TextStyle(color: Colors.red[400]),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValiditySection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.date_range, size: 18, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                ScheduleConstants.validityPeriod,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
              const Spacer(),
              if (onEditValidity != null)
                TextButton.icon(
                  onPressed: onEditValidity,
                  icon: Icon(Icons.edit, size: 16, color: Colors.blue[600]),
                  label: Text(
                    ScheduleConstants.editValidity,
                    style: TextStyle(fontSize: 12, color: Colors.blue[600]),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ScheduleConstants.validityFrom,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(startDate),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 30, color: Colors.blue[200]),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ScheduleConstants.validityTo,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(endDate),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: endDate == null
                              ? Colors.grey[500]
                              : Colors.black,
                          fontStyle: endDate == null
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
