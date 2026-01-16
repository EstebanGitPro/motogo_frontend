import 'package:motogo_frontend/src/core/catalogs/domain/entities/service_entity.dart';

/// Model for parsing service JSON from the API.
///
/// Handles JSON deserialization for services from the catalog endpoints.
class ServiceModel extends ServiceEntity {
  const ServiceModel({
    required super.id,
    required super.name,
    required super.description,
    required super.serviceType,
  });

  /// Creates a ServiceModel from JSON map.
  ///
  /// Expected JSON format:
  /// ```json
  /// {
  ///   "id": "abc123",
  ///   "name": "Cambio de aceite",
  ///   "description": "Cambio completo de aceite de motor",
  ///   "service_type": "Mantenimiento"
  /// }
  /// ```
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      serviceType: json['service_type'] as String? ?? '',
    );
  }

  /// Converts to ServiceEntity for domain layer use.
  ServiceEntity toEntity() {
    return ServiceEntity(
      id: id,
      name: name,
      description: description,
      serviceType: serviceType,
    );
  }
}
