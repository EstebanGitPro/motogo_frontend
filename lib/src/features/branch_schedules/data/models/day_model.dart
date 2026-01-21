import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/day_entity.dart';

/// Model for day catalog item with JSON serialization.
class DayModel extends DayEntity {
  const DayModel({required super.value, required super.label});

  /// Creates a model from JSON map.
  /// API returns: { "value": 1, "name": "Lunes" }
  factory DayModel.fromJson(Map<String, dynamic> json) {
    return DayModel(
      value: json['value']?.toString() ?? '',
      label: json['name']?.toString() ?? json['label']?.toString() ?? '',
    );
  }

  /// Converts the model to JSON map.
  Map<String, dynamic> toJson() {
    return {'value': value, 'label': label};
  }
}
