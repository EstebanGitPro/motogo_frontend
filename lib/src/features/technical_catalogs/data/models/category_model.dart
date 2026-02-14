import 'package:motogo_frontend/src/core/utils/json_helpers.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/entities/category_entity.dart';

/// Data model for motorcycle category with JSON serialization.
///
/// Parses the HATEOAS response from GET /motorcycle-categories endpoint.
class CategoryModel extends CategoryEntity {
  const CategoryModel({required super.name, required super.lineCount});

  /// Creates a model from JSON map (API response).
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      name: json['name'] as String? ?? '',
      lineCount: json['line_count'] as int? ?? 0,
    );
  }

  /// Parses list of categories from HATEOAS response.
  ///
  /// Expected format:
  /// ```json
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "categories": [{ "name": "...", "line_count": 1 }, ...]
  ///   }
  /// }
  /// ```
  static List<CategoryModel> fromJsonList(Map<String, dynamic> response) {
    return JsonHelpers.parseHateoasList(
      response,
      'categories',
      CategoryModel.fromJson,
    );
  }

  /// Converts model to domain entity.
  CategoryEntity toEntity() {
    return CategoryEntity(name: name, lineCount: lineCount);
  }
}
