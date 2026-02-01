import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/constants/schedule_constants.dart';

/// Dialog for creating or editing a time slot.
///
/// Returns a map with 'openingTime', 'closingTime', and 'isClosed' if confirmed.
class TimeSlotDialog extends StatefulWidget {
  final String dayName;
  final String? initialOpeningTime;
  final String? initialClosingTime;
  final bool initialIsClosed;
  final bool isEditing;

  const TimeSlotDialog({
    super.key,
    required this.dayName,
    this.initialOpeningTime,
    this.initialClosingTime,
    this.initialIsClosed = false,
    this.isEditing = false,
  });

  @override
  State<TimeSlotDialog> createState() => _TimeSlotDialogState();

  /// Shows the dialog and returns the result.
  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required String dayName,
    String? openingTime,
    String? closingTime,
    bool isClosed = false,
    bool isEditing = false,
  }) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => TimeSlotDialog(
        dayName: dayName,
        initialOpeningTime: openingTime,
        initialClosingTime: closingTime,
        initialIsClosed: isClosed,
        isEditing: isEditing,
      ),
    );
  }
}

class _TimeSlotDialogState extends State<TimeSlotDialog> {
  late TimeOfDay _openingTime;
  late TimeOfDay _closingTime;
  late bool _isClosed;

  @override
  void initState() {
    super.initState();
    _openingTime =
        _parseTime(widget.initialOpeningTime) ??
        const TimeOfDay(hour: 9, minute: 0);
    _closingTime =
        _parseTime(widget.initialClosingTime) ??
        const TimeOfDay(hour: 18, minute: 0);
    _isClosed = widget.initialIsClosed;
  }

  TimeOfDay? _parseTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;
    final parts = timeString.split(':');
    if (parts.length != 2) return null;
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickTime(bool isOpening) async {
    final initialTime = isOpening ? _openingTime : _closingTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isOpening) {
          _openingTime = picked;
        } else {
          _closingTime = picked;
        }
      });
    }
  }

  bool get _isValid {
    if (_isClosed) return true;
    // Opening time must be before closing time
    final openMinutes = _openingTime.hour * 60 + _openingTime.minute;
    final closeMinutes = _closingTime.hour * 60 + _closingTime.minute;
    return openMinutes < closeMinutes;
  }

  void _onConfirm() {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La hora de apertura debe ser anterior a la de cierre'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).pop({
      'openingTime': _formatTime(_openingTime),
      'closingTime': _formatTime(_closingTime),
      'isClosed': _isClosed,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            widget.isEditing ? Icons.edit : Icons.add_circle_outline,
            color: Colors.blue[600],
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              widget.isEditing
                  ? '${ScheduleConstants.editTimeSlot} - ${widget.dayName}'
                  : '${ScheduleConstants.addTimeSlot} - ${widget.dayName}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Closed toggle
          SwitchListTile(
            title: const Text(ScheduleConstants.closedAllDay),
            value: _isClosed,
            onChanged: (value) => setState(() => _isClosed = value),
            contentPadding: EdgeInsets.zero,
            activeTrackColor: Colors.red[400],
          ),
          if (!_isClosed) ...[
            const Divider(),
            // Opening time picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.wb_sunny_outlined, color: Colors.orange[600]),
              title: const Text(ScheduleConstants.openingTimeLabel),
              subtitle: Text(
                _formatTime(_openingTime),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              onTap: () => _pickTime(true),
            ),
            // Closing time picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.nights_stay_outlined,
                color: Colors.blue[600],
              ),
              title: const Text(ScheduleConstants.closingTimeLabel),
              subtitle: Text(
                _formatTime(_closingTime),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              onTap: () => _pickTime(false),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(ScheduleConstants.cancel),
        ),
        ElevatedButton(
          onPressed: _onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
          ),
          child: const Text(ScheduleConstants.save),
        ),
      ],
    );
  }
}
