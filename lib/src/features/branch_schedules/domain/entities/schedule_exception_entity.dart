import 'package:equatable/equatable.dart';

/// Entity representing a schedule exception for a date range.
///
/// Schedule exceptions override the regular schedule for a particular date
/// or date range, useful for holidays, special events, or temporary changes.
class ScheduleExceptionEntity extends Equatable {
  /// Unique identifier for this exception.
  final String id;

  /// Parent schedule ID.
  final String scheduleId;

  /// Exception start date in YYYY-MM-DD format (e.g., "2026-12-24").
  final String exceptionStartDate;

  /// Exception end date in YYYY-MM-DD format (e.g., "2026-12-31").
  /// If same as start date, it's a single-day exception.
  final String exceptionEndDate;

  /// Formatted start date for display (e.g., "24 de Diciembre, 2026").
  final String exceptionStartDateFormatted;

  /// Formatted end date for display. Only provided if different from start.
  final String? exceptionEndDateFormatted;

  /// Localized day name (e.g., "Martes") - refers to start date.
  final String dayName;

  /// Opening time in HH:mm format (e.g., "09:00").
  final String openingTime;

  /// Closing time in HH:mm format (e.g., "14:00").
  final String closingTime;

  /// Whether the branch is closed during this exception.
  final bool isClosed;

  /// Whether this exception is active.
  final bool active;

  const ScheduleExceptionEntity({
    required this.id,
    required this.scheduleId,
    required this.exceptionStartDate,
    required this.exceptionEndDate,
    required this.exceptionStartDateFormatted,
    this.exceptionEndDateFormatted,
    required this.dayName,
    required this.openingTime,
    required this.closingTime,
    required this.isClosed,
    required this.active,
  });

  /// Creates a copy with specified values overridden.
  ScheduleExceptionEntity copyWith({
    String? id,
    String? scheduleId,
    String? exceptionStartDate,
    String? exceptionEndDate,
    String? exceptionStartDateFormatted,
    String? exceptionEndDateFormatted,
    String? dayName,
    String? openingTime,
    String? closingTime,
    bool? isClosed,
    bool? active,
  }) {
    return ScheduleExceptionEntity(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      exceptionStartDate: exceptionStartDate ?? this.exceptionStartDate,
      exceptionEndDate: exceptionEndDate ?? this.exceptionEndDate,
      exceptionStartDateFormatted:
          exceptionStartDateFormatted ?? this.exceptionStartDateFormatted,
      exceptionEndDateFormatted:
          exceptionEndDateFormatted ?? this.exceptionEndDateFormatted,
      dayName: dayName ?? this.dayName,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      isClosed: isClosed ?? this.isClosed,
      active: active ?? this.active,
    );
  }

  /// Returns a display string for the time range.
  /// Example: "09:00 - 14:00" or "Cerrado"
  String get displayTimeRange {
    if (isClosed) return 'Cerrado';
    return '$openingTime - $closingTime';
  }

  /// Returns true if this is a date range exception (multiple days).
  bool get isDateRange =>
      exceptionEndDate.isNotEmpty && exceptionEndDate != exceptionStartDate;

  /// Checks if this exception is for a past date.
  bool get isPastDate {
    final exceptionDateTime = DateTime.tryParse(exceptionStartDate);
    if (exceptionDateTime == null) return false;
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    return exceptionDateTime.isBefore(todayOnly);
  }

  @override
  List<Object?> get props => [
    id,
    scheduleId,
    exceptionStartDate,
    exceptionEndDate,
    exceptionStartDateFormatted,
    exceptionEndDateFormatted,
    dayName,
    openingTime,
    closingTime,
    isClosed,
    active,
  ];
}
