import 'package:motogo_frontend/src/core/utils/json_helpers.dart';
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

  /// Parses list of rating ranges from HATEOAS response.
  ///
  /// Expected format:
  /// ```json
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "ratings": [{ "value": 5, "label": "Excellent" }, ...]
  ///   }
  /// }
  /// ```
  static List<RatingRangeModel> fromJsonList(Map<String, dynamic> response) {
    return JsonHelpers.parseHateoasList(
      response,
      'ratings',
      RatingRangeModel.fromJson,
    );
  }

  /// Converts to RatingRangeEntity for domain layer use.
  RatingRangeEntity toEntity() {
    return RatingRangeEntity(value: value, label: label);
  }
}
