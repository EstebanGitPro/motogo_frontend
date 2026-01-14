import 'package:motogo_frontend/src/core/catalogs/domain/entities/brand_entity.dart';

/// Data model for brand with JSON serialization.
///
/// Parses the HATEOAS response from GET /brands endpoint.
class BrandModel extends BrandEntity {
  const BrandModel({required super.id, required super.name});

  /// Creates a model from JSON map (API response).
  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(id: json['id'] as String, name: json['name'] as String);
  }

  /// Parses list of brands from HATEOAS response.
  ///
  /// Expected format:
  /// ```json
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "brands": [{ "id": "...", "name": "..." }, ...]
  ///   }
  /// }
  /// ```
  static List<BrandModel> fromJsonList(Map<String, dynamic> response) {
    final data = response['data'] as Map<String, dynamic>?;
    if (data == null) return [];

    final brands = data['brands'] as List<dynamic>?;
    if (brands == null) return [];

    return brands
        .map((json) => BrandModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Converts model to domain entity.
  BrandEntity toEntity() {
    return BrandEntity(id: id, name: name);
  }
}
