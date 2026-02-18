import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/constants/schedule_constants.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/repositories/branch_schedule_repository.dart';
import 'package:motogo_frontend/src/features/branch_schedules/presentation/bloc/branch_schedule_bloc.dart';
import 'package:motogo_frontend/src/features/branch_schedules/presentation/bloc/branch_schedule_event.dart';
import 'package:motogo_frontend/src/features/branch_schedules/presentation/bloc/branch_schedule_state.dart';
import 'package:motogo_frontend/src/features/branch_schedules/presentation/widgets/schedule_days_accordion.dart';
import 'package:motogo_frontend/src/features/branch_schedules/presentation/widgets/schedule_exception_list.dart';
import 'package:motogo_frontend/src/features/branch_schedules/presentation/widgets/schedule_status_card.dart';

/// Tab widget for managing branch schedules.
///
/// Shows schedule status with options to create, activate/deactivate,
/// and delete the schedule configuration.
class BranchScheduleTab extends StatelessWidget {
  final String branchId;
  final String branchName;

  const BranchScheduleTab({
    super.key,
    required this.branchId,
    required this.branchName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BranchScheduleBloc(
        repository: InjectorApp.resolve<BranchScheduleRepository>(),
      )..add(LoadSchedule(branchId)),
      child: BlocListener<BranchScheduleBloc, BranchScheduleState>(
        listenWhen: (prev, curr) => _hasMessage(curr),
        listener: _onStateChanged,
        child: _BranchScheduleContent(branchId: branchId),
      ),
    );
  }

  bool _hasMessage(BranchScheduleState state) {
    if (state is BranchScheduleLoaded && state.message != null) return true;
    if (state is BranchScheduleNotFound && state.message != null) return true;
    if (state is BranchScheduleError) return true;
    return false;
  }

  void _onStateChanged(BuildContext context, BranchScheduleState state) {
    final (message, isSuccess) = _extractMessage(state);
    if (message != null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isSuccess ? Colors.green[600] : Colors.red[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  (String?, bool) _extractMessage(BranchScheduleState state) {
    if (state is BranchScheduleLoaded && state.message != null) {
      return (state.message, state.isSuccess);
    }
    if (state is BranchScheduleNotFound && state.message != null) {
      return (state.message, state.isSuccess);
    }
    if (state is BranchScheduleError) {
      return (state.message, false);
    }
    return (null, true);
  }
}

class _BranchScheduleContent extends StatelessWidget {
  final String branchId;

  const _BranchScheduleContent({required this.branchId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BranchScheduleBloc, BranchScheduleState>(
      builder: (context, state) {
        if (state is BranchScheduleLoading ||
            state is BranchScheduleOperating) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is BranchScheduleNotFound) {
          return _buildNoScheduleState(context);
        }

        if (state is BranchScheduleLoaded) {
          return _buildScheduleLoadedState(context, state);
        }

        if (state is BranchScheduleError) {
          return _buildErrorState(context, state.message);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildNoScheduleState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.schedule_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              ScheduleConstants.emptyScheduleTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ScheduleConstants.emptyScheduleDescription,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.read<BranchScheduleBloc>().add(
                  CreateSchedule(branchId),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text(ScheduleConstants.createSchedule),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleLoadedState(
    BuildContext context,
    BranchScheduleLoaded state,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ScheduleStatusCard(
            isActive: state.schedule.active,
            startDate: state.schedule.startDate,
            endDate: state.schedule.endDate,
            onToggle: (value) {
              context.read<BranchScheduleBloc>().add(
                ToggleScheduleStatus(branchId: branchId, activate: value),
              );
            },
            onDelete: () => _showDeleteConfirmation(context),
            onEditValidity: () => _showEditValidityDialog(context, state),
          ),
          const SizedBox(height: 16),
          // Days accordion
          ScheduleDaysAccordion(
            branchId: branchId,
            daysCatalog: state.daysCatalog,
            detailsByDay: state.detailsByDay,
            isLoading: state.isDetailsLoading,
          ),
          const SizedBox(height: 24),
          // Schedule exceptions section
          ScheduleExceptionList(
            branchId: branchId,
            exceptions: state.exceptions,
            isLoading: state.isExceptionsLoading,
          ),
        ],
      ),
    );
  }

  void _showEditValidityDialog(
    BuildContext context,
    BranchScheduleLoaded state,
  ) {
    DateTime startDate = state.schedule.startDate ?? DateTime.now();
    DateTime? endDate = state.schedule.endDate;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.date_range, color: Colors.blue[600]),
                const SizedBox(width: 8),
                const Flexible(
                  child: Text(
                    ScheduleConstants.editValidityTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStartDatePicker(dialogContext, startDate, (picked) {
                  setState(() => startDate = picked);
                }),
                const Divider(),
                _buildEndDatePicker(
                  dialogContext,
                  startDate,
                  endDate,
                  (picked) {
                    setState(() => endDate = picked);
                  },
                  () {
                    setState(() => endDate = null);
                  },
                ),
              ],
            ),
            actions: _buildValidityDialogActions(
              dialogContext,
              context,
              state,
              startDate,
              endDate,
            ),
          );
        },
      ),
    );
  }

  Widget _buildStartDatePicker(
    BuildContext dialogContext,
    DateTime startDate,
    ValueChanged<DateTime> onPicked,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.calendar_today, color: Colors.blue[600]),
      title: const Text(ScheduleConstants.startDateLabel),
      subtitle: Text(
        '${startDate.day}/${startDate.month}/${startDate.year}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: dialogContext,
          initialDate: startDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          locale: const Locale('es', 'ES'),
        );
        if (picked != null) onPicked(picked);
      },
    );
  }

  Widget _buildEndDatePicker(
    BuildContext dialogContext,
    DateTime startDate,
    DateTime? endDate,
    ValueChanged<DateTime> onPicked,
    VoidCallback onClear,
  ) {
    final endLabel = endDate != null
        ? '${endDate.day}/${endDate.month}/${endDate.year}'
        : ScheduleConstants.validityIndefinite;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.event, color: Colors.orange[600]),
      title: const Text(ScheduleConstants.endDateLabel),
      subtitle: Text(
        endLabel,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontStyle: endDate == null ? FontStyle.italic : FontStyle.normal,
        ),
      ),
      trailing: endDate != null
          ? IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: onClear,
            )
          : null,
      onTap: () async {
        final picked = await showDatePicker(
          context: dialogContext,
          initialDate: endDate ?? startDate.add(const Duration(days: 365)),
          firstDate: startDate,
          lastDate: DateTime(2100),
          locale: const Locale('es', 'ES'),
        );
        if (picked != null) onPicked(picked);
      },
    );
  }

  List<Widget> _buildValidityDialogActions(
    BuildContext dialogContext,
    BuildContext context,
    BranchScheduleLoaded state,
    DateTime startDate,
    DateTime? endDate,
  ) {
    return [
      TextButton(
        onPressed: () => Navigator.pop(dialogContext),
        child: const Text(ScheduleConstants.cancel),
      ),
      ElevatedButton(
        onPressed: () {
          Navigator.pop(dialogContext);
          context.read<BranchScheduleBloc>().add(
            UpdateSchedule(
              branchId: branchId,
              active: state.schedule.active,
              startDate: startDate,
              endDate: endDate,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
        ),
        child: const Text(ScheduleConstants.save),
      ),
    ];
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<BranchScheduleBloc>().add(LoadSchedule(branchId));
              },
              child: const Text(ScheduleConstants.retry),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.red[600]),
            const SizedBox(width: 8),
            const Text(ScheduleConstants.deleteScheduleTitle),
          ],
        ),
        content: const Text(ScheduleConstants.deleteScheduleMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(ScheduleConstants.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<BranchScheduleBloc>().add(DeleteSchedule(branchId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text(ScheduleConstants.deleteScheduleConfirm),
          ),
        ],
      ),
    );
  }
}
