import 'package:motogo_frontend/src/core/catalogs/domain/entities/displacement_range_entity.dart';
import 'package:motogo_frontend/src/core/utils/json_helpers.dart';

/// Data model for displacement range with JSON serialization.
///
/// Parses the HATEOAS response from GET /engine-displacements.
class DisplacementRangeModel {
  final String range;

  const DisplacementRangeModel({required this.range});

  /// Creates a model from a single JSON object.
  factory DisplacementRangeModel.fromJson(Map<String, dynamic> json) {
    return DisplacementRangeModel(range: json['range'] as String? ?? '');
  }

  /// Parses a HATEOAS response containing a list of displacement ranges.
  ///
  /// Expected structure: `{ "data": { "displacements": [...] } }`
  static List<DisplacementRangeModel> fromJsonList(
    Map<String, dynamic> response,
  ) {
    return JsonHelpers.parseHateoasList(
      response,
      'displacements',
      DisplacementRangeModel.fromJson,
    );
  }

  /// Converts model to domain entity.
  DisplacementRangeEntity toEntity() {
    return DisplacementRangeEntity(range: range);
  }
}
