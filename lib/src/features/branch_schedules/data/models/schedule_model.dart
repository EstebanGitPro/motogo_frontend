import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_entity.dart';

/// Model for schedule with JSON serialization/deserialization.
class ScheduleModel extends ScheduleEntity {
  const ScheduleModel({
    required super.id,
    required super.branchId,
    required super.active,
    super.startDate,
    super.endDate,
  });

  /// Creates a model from JSON map.
  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id']?.toString() ?? '',
      branchId: json['branch_id']?.toString() ?? '',
      active: json['active'] as bool? ?? true,
      startDate: _parseDate(json['start_date']),
      endDate: _parseDate(json['end_date']),
    );
  }

  /// Parses a date string in YYYY-MM-DD format.
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  /// Formats a DateTime to YYYY-MM-DD string.
  static String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// Converts the model to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branch_id': branchId,
      'active': active,
      if (startDate != null) 'start_date': _formatDate(startDate),
      if (endDate != null) 'end_date': _formatDate(endDate),
    };
  }

  /// Converts to JSON for update request (only editable fields).
  Map<String, dynamic> toUpdateJson() {
    return {
      'active': active,
      if (startDate != null) 'start_date': _formatDate(startDate),
      'end_date': _formatDate(endDate), // Include even if null
    };
  }
}
