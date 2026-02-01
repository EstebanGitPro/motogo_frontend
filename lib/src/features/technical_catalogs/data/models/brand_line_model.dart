import 'package:motogo_frontend/src/features/technical_catalogs/domain/entities/brand_line_entity.dart';

/// Data model for brand line with JSON serialization.
///
/// Parses the HATEOAS response from GET /admin/brands/{id}/lines endpoint.
class BrandLineModel extends BrandLineEntity {
  const BrandLineModel({required super.brandName, required super.model});

  /// Creates a model from JSON map (API response).
  factory BrandLineModel.fromJson(Map<String, dynamic> json) {
    return BrandLineModel(
      brandName: json['brand_name'] as String? ?? '',
      model: json['model'] as String? ?? '',
    );
  }

  /// Parses list of brand lines from HATEOAS response.
  ///
  /// Expected format:
  /// ```json
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "lines": [{ "brand_name": "...", "model": "..." }, ...]
  ///   }
  /// }
  /// ```
  static List<BrandLineModel> fromJsonList(Map<String, dynamic> response) {
    final data = response['data'] as Map<String, dynamic>?;
    if (data == null) return [];

    final lines = data['lines'] as List<dynamic>?;
    if (lines == null) return [];

    return lines
        .map((json) => BrandLineModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Converts model to domain entity.
  BrandLineEntity toEntity() {
    return BrandLineEntity(brandName: brandName, model: model);
  }
}
