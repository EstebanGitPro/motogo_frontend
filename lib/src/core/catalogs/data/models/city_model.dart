import 'package:motogo_frontend/src/core/catalogs/domain/entities/city_entity.dart';

/// Data model for city with JSON serialization.
class CityModel extends CityEntity {
  const CityModel({required super.id, required super.name});

  /// Creates a model from JSON map.
  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(id: json['id'] as String, name: json['name'] as String);
  }

  /// Parses list of cities from HATEOAS response.
  static List<CityModel> fromJsonList(Map<String, dynamic> response) {
    final data = response['data'] as Map<String, dynamic>?;
    if (data == null) return [];

    final cities = data['cities'] as List<dynamic>?;
    if (cities == null) return [];

    return cities
        .map((json) => CityModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Converts model to domain entity.
  CityEntity toEntity() {
    return CityEntity(id: id, name: name);
  }
}
