import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motogo_frontend/src/core/constants/schedule_constants.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_exception_entity.dart';

/// Dialog for creating or editing a schedule exception.
class ScheduleExceptionDialog extends StatefulWidget {
  final String branchId;
  final ScheduleExceptionEntity? exception;
  final List<ScheduleExceptionEntity> existingExceptions;
  final void Function(
    String exceptionStartDate,
    String? exceptionEndDate,
    String openingTime,
    String closingTime,
    bool isClosed,
  )
  onSave;

  const ScheduleExceptionDialog({
    super.key,
    required this.branchId,
    this.exception,
    this.existingExceptions = const [],
    required this.onSave,
  });

  @override
  State<ScheduleExceptionDialog> createState() =>
      _ScheduleExceptionDialogState();
}

class _ScheduleExceptionDialogState extends State<ScheduleExceptionDialog> {
  late DateTime _selectedStartDate;
  late DateTime? _selectedEndDate;
  late TimeOfDay _openingTime;
  late TimeOfDay _closingTime;
  late bool _isClosed;
  late bool _isDateRange;

  bool get _isEditing => widget.exception != null;

  @override
  void initState() {
    super.initState();
    if (widget.exception != null) {
      _selectedStartDate =
          DateTime.tryParse(widget.exception!.exceptionStartDate) ??
          DateTime.now().add(const Duration(days: 1));
      final endDate = DateTime.tryParse(widget.exception!.exceptionEndDate);
      _selectedEndDate = (endDate != null && endDate != _selectedStartDate)
          ? endDate
          : null;
      _isDateRange = _selectedEndDate != null;
      _openingTime =
          _parseTime(widget.exception!.openingTime) ??
          const TimeOfDay(hour: 9, minute: 0);
      _closingTime =
          _parseTime(widget.exception!.closingTime) ??
          const TimeOfDay(hour: 18, minute: 0);
      _isClosed = widget.exception!.isClosed;
    } else {
      _selectedStartDate = DateTime.now().add(const Duration(days: 1));
      _selectedEndDate = null;
      _isDateRange = false;
      _openingTime = const TimeOfDay(hour: 9, minute: 0);
      _closingTime = const TimeOfDay(hour: 18, minute: 0);
      _isClosed = false;
    }
  }

  TimeOfDay? _parseTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;
    final parts = timeString.split(':');
    if (parts.length < 2) return null;
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDisplayDate(DateTime date) {
    return DateFormat('EEEE, d MMMM yyyy', 'es_ES').format(date);
  }

  Future<void> _pickStartDate() async {
    final today = DateTime.now();
    final firstDate = DateTime(today.year, today.month, today.day);
    final lastDate = DateTime(today.year + 2, 12, 31);

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate.isBefore(firstDate)
          ? firstDate
          : _selectedStartDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('es', 'ES'),
    );

    if (picked != null) {
      setState(() {
        _selectedStartDate = picked;
        // Reset end date if before start date
        if (_selectedEndDate != null && _selectedEndDate!.isBefore(picked)) {
          _selectedEndDate = null;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    // End date must be on or after start date
    final firstDate = _selectedStartDate;
    final lastDate = DateTime(_selectedStartDate.year + 2, 12, 31);

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? _selectedStartDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('es', 'ES'),
    );

    if (picked != null) {
      setState(() => _selectedEndDate = picked);
    }
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

  /// Check if the selected date range overlaps with any existing exception
  bool _hasDateOverlap() {
    // Skip validation when editing (dates can't change anyway)
    if (_isEditing) return false;

    final newStart = _selectedStartDate;
    final newEnd = _isDateRange && _selectedEndDate != null
        ? _selectedEndDate!
        : _selectedStartDate;

    for (final existing in widget.existingExceptions) {
      final existingStart = DateTime.tryParse(existing.exceptionStartDate);
      final existingEnd =
          DateTime.tryParse(existing.exceptionEndDate) ?? existingStart;

      if (existingStart == null) continue;

      // Check for any date overlap
      // Overlap occurs when: newStart <= existingEnd AND newEnd >= existingStart
      if (newStart.compareTo(existingEnd!) <= 0 &&
          newEnd.compareTo(existingStart) >= 0) {
        return true;
      }
    }
    return false;
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

    // Validate no date overlap with existing exceptions
    if (_hasDateOverlap()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ya existe una excepción para las fechas seleccionadas',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pop(context);
    widget.onSave(
      _formatDate(_selectedStartDate),
      _isDateRange && _selectedEndDate != null
          ? _formatDate(_selectedEndDate!)
          : null,
      _formatTime(_openingTime),
      _formatTime(_closingTime),
      _isClosed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _isEditing ? Icons.edit : Icons.add_circle_outline,
            color: Colors.orange[600],
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              _isEditing
                  ? ScheduleConstants.editExceptionTitle
                  : ScheduleConstants.newExceptionTitle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Start date picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.calendar_today, color: Colors.orange[600]),
              title: Text(
                _isDateRange
                    ? ScheduleConstants.exceptionStartDateLabel
                    : ScheduleConstants.exceptionDateLabel,
              ),
              subtitle: Text(
                _formatDisplayDate(_selectedStartDate),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              onTap: _isEditing ? null : _pickStartDate,
              trailing: _isEditing
                  ? Icon(Icons.lock_outline, color: Colors.grey[400], size: 18)
                  : Icon(Icons.chevron_right, color: Colors.grey[400]),
            ),

            // Date range toggle (only for new exceptions)
            if (!_isEditing) ...[
              SwitchListTile(
                title: Text(ScheduleConstants.dateRangeToggle),
                value: _isDateRange,
                onChanged: (value) {
                  setState(() {
                    _isDateRange = value;
                    if (!value) _selectedEndDate = null;
                  });
                },
                contentPadding: EdgeInsets.zero,
                activeColor: Colors.orange[600],
              ),
            ],

            // End date picker (only if date range enabled)
            if (_isDateRange) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.event, color: Colors.orange[600]),
                title: Text(ScheduleConstants.exceptionEndDateLabel),
                subtitle: Text(
                  _selectedEndDate != null
                      ? _formatDisplayDate(_selectedEndDate!)
                      : 'Seleccionar fecha',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: _selectedEndDate == null
                        ? Colors.grey[500]
                        : Colors.black87,
                  ),
                ),
                onTap: _isEditing ? null : _pickEndDate,
                trailing: _isEditing
                    ? Icon(
                        Icons.lock_outline,
                        color: Colors.grey[400],
                        size: 18,
                      )
                    : Icon(Icons.chevron_right, color: Colors.grey[400]),
              ),
            ],

            const Divider(),

            // Closed toggle
            SwitchListTile(
              title: Text(ScheduleConstants.closedThisDay),
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
                leading: Icon(
                  Icons.wb_sunny_outlined,
                  color: Colors.orange[600],
                ),
                title: const Text(ScheduleConstants.exceptionOpeningTimeLabel),
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
                title: const Text(ScheduleConstants.exceptionClosingTimeLabel),
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(ScheduleConstants.cancel),
        ),
        ElevatedButton(
          onPressed: _onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[600],
            foregroundColor: Colors.white,
          ),
          child: const Text(ScheduleConstants.save),
        ),
      ],
    );
  }
}
