import 'package:equatable/equatable.dart';

/// Entity representing a time slot for a specific day in a branch schedule.
///
/// Each schedule can have multiple details per day (e.g., morning and afternoon shifts).
class ScheduleDetailEntity extends Equatable {
  /// Unique identifier for this time slot.
  final String id;

  /// Parent schedule ID.
  final String scheduleId;

  /// Day of the week (1 = Monday, 7 = Sunday).
  final int dayOfWeek;

  /// Localized day name (e.g., "Lunes", "Martes").
  final String dayName;

  /// Opening time in HH:mm format (e.g., "08:00").
  final String openingTime;

  /// Closing time in HH:mm format (e.g., "18:00").
  final String closingTime;

  /// Whether the branch is closed for this time slot.
  final bool isClosed;

  /// Whether this detail is active.
  final bool active;

  const ScheduleDetailEntity({
    // NOSONAR - 8 campos atómicos de un slot horario
    required this.id,
    required this.scheduleId,
    required this.dayOfWeek,
    required this.dayName,
    required this.openingTime,
    required this.closingTime,
    required this.isClosed,
    required this.active,
  });

  /// Creates a copy with specified values overridden.
  ScheduleDetailEntity copyWith({
    // NOSONAR - copyWith refleja los mismos 8 campos del constructor
    String? id,
    String? scheduleId,
    int? dayOfWeek,
    String? dayName,
    String? openingTime,
    String? closingTime,
    bool? isClosed,
    bool? active,
  }) {
    return ScheduleDetailEntity(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      dayName: dayName ?? this.dayName,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      isClosed: isClosed ?? this.isClosed,
      active: active ?? this.active,
    );
  }

  /// Returns a display string for the time range.
  /// Example: "08:00 - 12:00" or "Cerrado"
  String get displayTimeRange {
    if (isClosed) return 'Cerrado';
    return '$openingTime - $closingTime';
  }

  @override
  List<Object?> get props => [
    id,
    scheduleId,
    dayOfWeek,
    dayName,
    openingTime,
    closingTime,
    isClosed,
    active,
  ];
}
