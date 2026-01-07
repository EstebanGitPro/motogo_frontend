import 'package:motogo_frontend/src/core/catalogs/domain/entities/department_entity.dart';

/// Data model for department with JSON serialization.
class DepartmentModel extends DepartmentEntity {
  const DepartmentModel({required super.id, required super.name});

  /// Creates a model from JSON map.
  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  /// Parses list of departments from HATEOAS response.
  static List<DepartmentModel> fromJsonList(Map<String, dynamic> response) {
    final data = response['data'] as Map<String, dynamic>?;
    if (data == null) return [];

    final departments = data['departments'] as List<dynamic>?;
    if (departments == null) return [];

    return departments
        .map((json) => DepartmentModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Converts model to domain entity.
  DepartmentEntity toEntity() {
    return DepartmentEntity(id: id, name: name);
  }
}
