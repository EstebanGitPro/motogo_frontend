import 'package:motogo_frontend/src/core/utils/json_helpers.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/entities/category_line_entity.dart';

/// Data model for a motorcycle line within a category.
///
/// Parses the HATEOAS response from GET /motorcycle-categories/{name}/lines.
class CategoryLineModel extends CategoryLineEntity {
  const CategoryLineModel({
    required super.model,
    required super.brand,
    required super.engineDisplacement,
  });

  /// Creates a model from JSON map (API response).
  factory CategoryLineModel.fromJson(Map<String, dynamic> json) {
    return CategoryLineModel(
      model: json['model'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      engineDisplacement: json['engine_displacement'] as int? ?? 0,
    );
  }

  /// Parses list of category lines from HATEOAS response.
  ///
  /// Expected format:
  /// ```json
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "category": "Adventure",
  ///     "lines": [{ "model": "...", "brand": "...", "engine_displacement": 373 }, ...]
  ///   }
  /// }
  /// ```
  static List<CategoryLineModel> fromJsonList(Map<String, dynamic> response) {
    return JsonHelpers.parseHateoasList(
      response,
      'lines',
      CategoryLineModel.fromJson,
    );
  }

  /// Converts model to domain entity.
  CategoryLineEntity toEntity() {
    return CategoryLineEntity(
      model: model,
      brand: brand,
      engineDisplacement: engineDisplacement,
    );
  }
}
