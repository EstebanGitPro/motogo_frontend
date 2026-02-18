import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/constants/schedule_constants.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_exception_entity.dart';

/// Card widget for displaying a single schedule exception with actions.
class ScheduleExceptionCard extends StatelessWidget {
  final ScheduleExceptionEntity exception;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  const ScheduleExceptionCard({
    super.key,
    required this.exception,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isPast = exception.isPastDate;
    final isActive = exception.active;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _getBackgroundColor(isPast, isActive),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getBorderColor(isPast, isActive)),
      ),
      child: Row(
        children: [
          Icon(Icons.event, size: 18, color: _getIconColor(isPast, isActive)),
          const SizedBox(width: 10),
          Expanded(child: _buildDateInfo(isPast)),
          _buildStatusBadge(),
          const SizedBox(width: 4),
          _buildActionsMenu(),
        ],
      ),
    );
  }

  Widget _buildDateInfo(bool isPast) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getDisplayDate(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isPast ? Colors.grey[500] : Colors.grey[800],
          ),
        ),
        const SizedBox(height: 2),
        _buildDayNameRow(),
      ],
    );
  }

  Widget _buildDayNameRow() {
    return Row(
      children: [
        Text(
          exception.dayName,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        if (exception.isDateRange)
          Text(
            ' • ${ScheduleConstants.exceptionRangeLabel}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.orange[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        const SizedBox(width: 8),
        Text(
          exception.displayTimeRange,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: exception.isClosed ? Colors.red[600] : Colors.grey[700],
          ),
        ),
      ],
    );
  }

  /// Returns the display date, handling date ranges.
  String _getDisplayDate() {
    if (exception.isDateRange) {
      final startFormatted = _resolveStartDate();
      final endFormatted = _resolveEndDate();
      return '$startFormatted - $endFormatted';
    }
    return _resolveStartDate();
  }

  String _resolveStartDate() {
    if (exception.exceptionStartDateFormatted.isNotEmpty) {
      return exception.exceptionStartDateFormatted;
    }
    return exception.exceptionStartDate;
  }

  String _resolveEndDate() {
    final formatted = exception.exceptionEndDateFormatted;
    if (formatted != null && formatted.isNotEmpty) {
      return formatted;
    }
    return exception.exceptionEndDate;
  }

  Color _getBackgroundColor(bool isPast, bool isActive) {
    if (isPast) return Colors.grey[100]!;
    if (!isActive) return Colors.grey[50]!;
    if (exception.isClosed) return Colors.red[50]!;
    return Colors.blue[50]!;
  }

  Color _getBorderColor(bool isPast, bool isActive) {
    if (isPast) return Colors.grey[300]!;
    if (!isActive) return Colors.grey[200]!;
    if (exception.isClosed) return Colors.red[200]!;
    return Colors.blue[200]!;
  }

  Color _getIconColor(bool isPast, bool isActive) {
    if (isPast) return Colors.grey[400]!;
    if (!isActive) return Colors.grey[500]!;
    if (exception.isClosed) return Colors.red[400]!;
    return Colors.blue[400]!;
  }

  /// Builds the status badge (Expirada / Activa / Inactiva).
  Widget _buildStatusBadge() {
    final isPast = exception.isPastDate;
    final isActive = exception.active;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _statusBadgeColor(isPast, isActive),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _statusLabel(isPast, isActive),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: _statusTextColor(isPast, isActive),
        ),
      ),
    );
  }

  Color _statusBadgeColor(bool isPast, bool isActive) {
    if (isPast) return Colors.orange[50]!;
    if (isActive) return Colors.green[50]!;
    return Colors.grey[100]!;
  }

  String _statusLabel(bool isPast, bool isActive) {
    if (isPast) return ScheduleConstants.exceptionStatusExpired;
    if (isActive) return ScheduleConstants.exceptionStatusActive;
    return ScheduleConstants.exceptionStatusInactive;
  }

  Color _statusTextColor(bool isPast, bool isActive) {
    if (isPast) return Colors.orange[700]!;
    if (isActive) return Colors.green[700]!;
    return Colors.grey[600]!;
  }

  /// Builds the actions popup menu.
  Widget _buildActionsMenu() {
    final isPast = exception.isPastDate;
    final isActive = exception.active;

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, size: 20, color: Colors.grey[600]),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      onSelected: _handleMenuAction,
      itemBuilder: (context) => [
        if (!isPast) ..._buildFutureMenuItems(isActive),
        _buildDeleteMenuItem(),
      ],
    );
  }

  void _handleMenuAction(String value) {
    switch (value) {
      case 'edit':
        onEdit();
      case 'toggle':
        onToggleStatus();
      case 'delete':
        onDelete();
    }
  }

  List<PopupMenuEntry<String>> _buildFutureMenuItems(bool isActive) {
    return [
      PopupMenuItem<String>(
        value: 'edit',
        child: Row(
          children: [
            Icon(Icons.edit_outlined, size: 18, color: Colors.blue[600]),
            const SizedBox(width: 8),
            const Text(ScheduleConstants.editException),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'toggle',
        child: Row(
          children: [
            Icon(
              isActive ? Icons.visibility_off : Icons.visibility,
              size: 18,
              color: Colors.orange[600],
            ),
            const SizedBox(width: 8),
            Text(
              isActive
                  ? ScheduleConstants.toggleDeactivate
                  : ScheduleConstants.toggleActivate,
            ),
          ],
        ),
      ),
    ];
  }

  PopupMenuItem<String> _buildDeleteMenuItem() {
    return PopupMenuItem<String>(
      value: 'delete',
      child: Row(
        children: [
          Icon(Icons.delete_outline, size: 18, color: Colors.red[400]),
          const SizedBox(width: 8),
          const Text(ScheduleConstants.deleteException),
        ],
      ),
    );
  }
}
