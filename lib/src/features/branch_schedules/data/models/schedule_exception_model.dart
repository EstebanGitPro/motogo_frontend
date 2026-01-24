import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_exception_entity.dart';

/// Model for schedule exception data from the API.
///
/// Maps to the /schedule-exceptions endpoint response.
class ScheduleExceptionModel extends ScheduleExceptionEntity {
  const ScheduleExceptionModel({
    required super.id,
    required super.scheduleId,
    required super.exceptionStartDate,
    required super.exceptionEndDate,
    required super.exceptionStartDateFormatted,
    super.exceptionEndDateFormatted,
    required super.dayName,
    required super.openingTime,
    required super.closingTime,
    required super.isClosed,
    required super.active,
  });

  /// Creates a model from JSON API response.
  factory ScheduleExceptionModel.fromJson(Map<String, dynamic> json) {
    return ScheduleExceptionModel(
      id: json['id'] as String? ?? '',
      scheduleId: json['schedule_id'] as String? ?? '',
      exceptionStartDate: json['exception_start_date'] as String? ?? '',
      exceptionEndDate: json['exception_end_date'] as String? ?? '',
      exceptionStartDateFormatted:
          json['exception_start_date_formatted'] as String? ?? '',
      exceptionEndDateFormatted:
          json['exception_end_date_formatted'] as String?,
      dayName: json['day_name'] as String? ?? '',
      openingTime: json['opening_time'] as String? ?? '00:00',
      closingTime: json['closing_time'] as String? ?? '00:00',
      isClosed: json['is_closed'] as bool? ?? false,
      active: json['active'] as bool? ?? true,
    );
  }

  /// Converts the model to JSON for API requests (create).
  Map<String, dynamic> toJson() {
    return {
      'exception_start_date': exceptionStartDate,
      if (exceptionEndDate.isNotEmpty) 'exception_end_date': exceptionEndDate,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'is_closed': isClosed,
    };
  }

  /// Converts to JSON for update requests (dates cannot be modified).
  Map<String, dynamic> toUpdateJson() {
    return {
      'opening_time': openingTime,
      'closing_time': closingTime,
      'is_closed': isClosed,
    };
  }

  /// Creates a model from an entity.
  factory ScheduleExceptionModel.fromEntity(ScheduleExceptionEntity entity) {
    return ScheduleExceptionModel(
      id: entity.id,
      scheduleId: entity.scheduleId,
      exceptionStartDate: entity.exceptionStartDate,
      exceptionEndDate: entity.exceptionEndDate,
      exceptionStartDateFormatted: entity.exceptionStartDateFormatted,
      exceptionEndDateFormatted: entity.exceptionEndDateFormatted,
      dayName: entity.dayName,
      openingTime: entity.openingTime,
      closingTime: entity.closingTime,
      isClosed: entity.isClosed,
      active: entity.active,
    );
  }

  /// Converts to domain entity.
  ScheduleExceptionEntity toEntity() {
    return ScheduleExceptionEntity(
      id: id,
      scheduleId: scheduleId,
      exceptionStartDate: exceptionStartDate,
      exceptionEndDate: exceptionEndDate,
      exceptionStartDateFormatted: exceptionStartDateFormatted,
      exceptionEndDateFormatted: exceptionEndDateFormatted,
      dayName: dayName,
      openingTime: openingTime,
      closingTime: closingTime,
      isClosed: isClosed,
      active: active,
    );
  }
}
