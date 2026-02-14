import 'package:motogo_frontend/src/features/service_ratings/domain/entities/rating_range_entity.dart';

/// Model for parsing rating range JSON from the API.
///
/// Handles JSON deserialization for rating range options.
class RatingRangeModel extends RatingRangeEntity {
  const RatingRangeModel({required super.value, required super.label});

  /// Creates a RatingRangeModel from JSON map.
  ///
  /// Expected JSON format:
  /// ```json
  /// {
  ///   "value": 5,
  ///   "label": "Excellent"
  /// }
  /// ```
  factory RatingRangeModel.fromJson(Map<String, dynamic> json) {
    return RatingRangeModel(
      value: json['value'] as int? ?? 0,
      label: json['label'] as String? ?? '',
    );
  }

  /// Converts to RatingRangeEntity for domain layer use.
  RatingRangeEntity toEntity() {
    return RatingRangeEntity(value: value, label: label);
  }
}
