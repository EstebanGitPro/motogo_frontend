import 'package:flutter/material.dart';

/// Shared time utilities for parsing, formatting, and picking times.
///
/// Used across schedule-related dialogs to avoid code duplication.
class TimeUtils {
  /// Parses a "HH:mm" string into a [TimeOfDay].
  ///
  /// Returns `null` if the string is null, empty, or malformed.
  static TimeOfDay? parseTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;
    final parts = timeString.split(':');
    if (parts.length < 2) return null;
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  /// Formats a [TimeOfDay] into a "HH:mm" string.
  static String formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  /// Shows a 24-hour time picker and returns the selected [TimeOfDay].
  ///
  /// Returns `null` if the user dismisses the picker.
  static Future<TimeOfDay?> pickTime(
    BuildContext context,
    TimeOfDay initialTime,
  ) {
    return showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
  }

  /// Validates that opening time is before closing time.
  static bool isValidTimeRange(TimeOfDay opening, TimeOfDay closing) {
    final openMinutes = opening.hour * 60 + opening.minute;
    final closeMinutes = closing.hour * 60 + closing.minute;
    return openMinutes < closeMinutes;
  }
}
