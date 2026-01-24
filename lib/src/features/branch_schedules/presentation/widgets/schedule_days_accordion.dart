import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/constants/schedule_constants.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/day_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_detail_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/presentation/bloc/branch_schedule_bloc.dart';
import 'package:motogo_frontend/src/features/branch_schedules/presentation/bloc/branch_schedule_event.dart';
import 'package:motogo_frontend/src/features/branch_schedules/presentation/widgets/day_accordion_tile.dart';
import 'package:motogo_frontend/src/features/branch_schedules/presentation/widgets/time_slot_dialog.dart';

/// Accordion list of all days with their time slots.
///
/// Manages expand/collapse state and delegates CRUD operations to the BLoC.
class ScheduleDaysAccordion extends StatefulWidget {
  final String branchId;
  final List<DayEntity> daysCatalog;
  final Map<int, List<ScheduleDetailEntity>> detailsByDay;
  final bool isLoading;

  const ScheduleDaysAccordion({
    super.key,
    required this.branchId,
    required this.daysCatalog,
    required this.detailsByDay,
    this.isLoading = false,
  });

  @override
  State<ScheduleDaysAccordion> createState() => _ScheduleDaysAccordionState();
}

class _ScheduleDaysAccordionState extends State<ScheduleDaysAccordion> {
  /// Tracks which day is currently expanded (null = all collapsed).
  int? _expandedDayNumber;

  void _onToggleDay(int dayNumber) {
    setState(() {
      _expandedDayNumber = _expandedDayNumber == dayNumber ? null : dayNumber;
    });
  }

  Future<void> _onAddTimeSlot(DayEntity day, int dayNumber) async {
    final result = await TimeSlotDialog.show(context, dayName: day.label);

    if (result != null && mounted) {
      context.read<BranchScheduleBloc>().add(
        CreateScheduleDetail(
          branchId: widget.branchId,
          dayOfWeek: dayNumber,
          openingTime: result['openingTime'] as String,
          closingTime: result['closingTime'] as String,
          isClosed: result['isClosed'] as bool,
        ),
      );
    }
  }

  Future<void> _onEditTimeSlot(
    ScheduleDetailEntity detail,
    DayEntity day,
  ) async {
    final result = await TimeSlotDialog.show(
      context,
      dayName: day.label,
      openingTime: detail.openingTime,
      closingTime: detail.closingTime,
      isClosed: detail.isClosed,
      isEditing: true,
    );

    if (result != null && mounted) {
      context.read<BranchScheduleBloc>().add(
        UpdateScheduleDetail(
          branchId: widget.branchId,
          detailId: detail.id,
          openingTime: result['openingTime'] as String,
          closingTime: result['closingTime'] as String,
          isClosed: result['isClosed'] as bool,
        ),
      );
    }
  }

  void _onDeleteTimeSlot(ScheduleDetailEntity detail) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.red[600]),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                ScheduleConstants.deleteTimeSlotTitle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: const Text(ScheduleConstants.deleteTimeSlotMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(ScheduleConstants.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<BranchScheduleBloc>().add(
                DeleteScheduleDetail(
                  branchId: widget.branchId,
                  detailId: detail.id,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text(ScheduleConstants.deleteTimeSlotConfirm),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.daysCatalog.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          ScheduleConstants.loadingDays,
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ScheduleConstants.daysOfAttention,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                // Days accordion list
                ...widget.daysCatalog.map((day) {
                  // dayNumber comes from the catalog's value (1-7 for Monday-Sunday)
                  final dayNumber = int.tryParse(day.value) ?? 1;
                  final timeSlots = widget.detailsByDay[dayNumber] ?? [];

                  return DayAccordionTile(
                    day: day,
                    dayNumber: dayNumber,
                    timeSlots: timeSlots,
                    isExpanded: _expandedDayNumber == dayNumber,
                    onToggleExpand: () => _onToggleDay(dayNumber),
                    onAddTimeSlot: () => _onAddTimeSlot(day, dayNumber),
                    onEditTimeSlot: (detail) => _onEditTimeSlot(detail, day),
                    onDeleteTimeSlot: _onDeleteTimeSlot,
                  );
                }),
              ],
            ),
          ),
        ),
        // Loading overlay
        if (widget.isLoading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
