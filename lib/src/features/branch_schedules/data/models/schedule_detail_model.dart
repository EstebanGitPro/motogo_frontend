import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_detail_entity.dart';

/// Model for schedule detail data from the API.
///
/// Maps to the /schedule-details endpoint response.
class ScheduleDetailModel extends ScheduleDetailEntity {
  const ScheduleDetailModel({
    required super.id,
    required super.scheduleId,
    required super.dayOfWeek,
    required super.dayName,
    required super.openingTime,
    required super.closingTime,
    required super.isClosed,
    required super.active,
  });

  /// Creates a model from JSON API response.
  factory ScheduleDetailModel.fromJson(Map<String, dynamic> json) {
    return ScheduleDetailModel(
      id: json['id'] as String? ?? '',
      scheduleId: json['schedule_id'] as String? ?? '',
      dayOfWeek: json['day_of_week'] as int? ?? 1,
      dayName: json['day_name'] as String? ?? '',
      openingTime: json['opening_time'] as String? ?? '00:00',
      closingTime: json['closing_time'] as String? ?? '00:00',
      isClosed: json['is_closed'] as bool? ?? false,
      active: json['active'] as bool? ?? true,
    );
  }

  /// Converts the model to JSON for API requests.
  Map<String, dynamic> toJson() {
    return {
      'day_of_week': dayOfWeek,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'is_closed': isClosed,
    };
  }

  /// Creates a model from an entity.
  factory ScheduleDetailModel.fromEntity(ScheduleDetailEntity entity) {
    return ScheduleDetailModel(
      id: entity.id,
      scheduleId: entity.scheduleId,
      dayOfWeek: entity.dayOfWeek,
      dayName: entity.dayName,
      openingTime: entity.openingTime,
      closingTime: entity.closingTime,
      isClosed: entity.isClosed,
      active: entity.active,
    );
  }

  /// Converts to domain entity.
  ScheduleDetailEntity toEntity() {
    return ScheduleDetailEntity(
      id: id,
      scheduleId: scheduleId,
      dayOfWeek: dayOfWeek,
      dayName: dayName,
      openingTime: openingTime,
      closingTime: closingTime,
      isClosed: isClosed,
      active: active,
    );
  }
}
