import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/constants/schedule_constants.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_exception_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/presentation/bloc/branch_schedule_bloc.dart';
import 'package:motogo_frontend/src/features/branch_schedules/presentation/bloc/branch_schedule_event.dart';
import 'package:motogo_frontend/src/features/branch_schedules/presentation/widgets/schedule_exception_card.dart';
import 'package:motogo_frontend/src/features/branch_schedules/presentation/widgets/schedule_exception_dialog.dart';

/// Widget for displaying and managing schedule exceptions.
class ScheduleExceptionList extends StatelessWidget {
  final String branchId;
  final List<ScheduleExceptionEntity> exceptions;
  final bool isLoading;

  const ScheduleExceptionList({
    super.key,
    required this.branchId,
    required this.exceptions,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Sort exceptions by start date (nearest first)
    final sortedExceptions = List<ScheduleExceptionEntity>.from(exceptions)
      ..sort((a, b) => a.exceptionStartDate.compareTo(b.exceptionStartDate));

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and add button
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 20,
                        color: Colors.orange[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ScheduleConstants.exceptionsTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddExceptionDialog(context),
                    icon: Icon(Icons.add, size: 18, color: Colors.orange[600]),
                    label: Text(
                      ScheduleConstants.addException,
                      style: TextStyle(fontSize: 13, color: Colors.orange[600]),
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
            ),
            // Exceptions list or empty state
            if (sortedExceptions.isEmpty)
              _buildEmptyState()
            else
              ...sortedExceptions.map(
                (exception) => ScheduleExceptionCard(
                  exception: exception,
                  onEdit: () => _showEditExceptionDialog(context, exception),
                  onDelete: () => _showDeleteConfirmation(context, exception),
                  onToggleStatus: () =>
                      _toggleExceptionStatus(context, exception),
                ),
              ),
          ],
        ),
        // Loading overlay
        if (isLoading)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
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

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.event_available, size: 32, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              ScheduleConstants.noExceptions,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddExceptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => ScheduleExceptionDialog(
        branchId: branchId,
        existingExceptions: exceptions,
        onSave: (startDate, endDate, openingTime, closingTime, isClosed) {
          context.read<BranchScheduleBloc>().add(
            CreateScheduleException(
              branchId: branchId,
              exceptionStartDate: startDate,
              exceptionEndDate: endDate,
              openingTime: openingTime,
              closingTime: closingTime,
              isClosed: isClosed,
            ),
          );
        },
      ),
    );
  }

  void _showEditExceptionDialog(
    BuildContext context,
    ScheduleExceptionEntity exception,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => ScheduleExceptionDialog(
        branchId: branchId,
        exception: exception,
        onSave: (startDate, endDate, openingTime, closingTime, isClosed) {
          // Note: dates cannot be modified, but we receive them anyway
          context.read<BranchScheduleBloc>().add(
            UpdateScheduleException(
              branchId: branchId,
              exceptionId: exception.id,
              openingTime: openingTime,
              closingTime: closingTime,
              isClosed: isClosed,
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    ScheduleExceptionEntity exception,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(ScheduleConstants.deleteExceptionTitle),
        content: const Text(ScheduleConstants.deleteExceptionMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(ScheduleConstants.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<BranchScheduleBloc>().add(
                DeleteScheduleException(
                  branchId: branchId,
                  exceptionId: exception.id,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(ScheduleConstants.deleteExceptionConfirm),
          ),
        ],
      ),
    );
  }

  void _toggleExceptionStatus(
    BuildContext context,
    ScheduleExceptionEntity exception,
  ) {
    context.read<BranchScheduleBloc>().add(
      ToggleScheduleExceptionStatus(
        branchId: branchId,
        exceptionId: exception.id,
        activate: !exception.active,
      ),
    );
  }
}
