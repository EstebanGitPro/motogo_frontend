import 'package:motogo_frontend/src/features/admin_services/domain/entities/admin_service_entity.dart';

/// Model for admin service with JSON serialization/deserialization.
class AdminServiceModel extends AdminServiceEntity {
  const AdminServiceModel({
    required super.id,
    required super.name,
    super.description,
    required super.serviceType,
    required super.isActive,
  });

  /// Creates a model from JSON map.
  factory AdminServiceModel.fromJson(Map<String, dynamic> json) {
    // Parse is_active - can be bool, int (1/0), or string
    bool isActive = false;
    final rawActive = json['is_active'];
    if (rawActive is bool) {
      isActive = rawActive;
    } else if (rawActive is int) {
      isActive = rawActive == 1;
    } else if (rawActive is String) {
      isActive = rawActive.toLowerCase() == 'true' || rawActive == '1';
    }

    return AdminServiceModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      serviceType: json['service_type']?.toString() ?? '',
      isActive: isActive,
    );
  }

  /// Creates a model from a domain entity.
  factory AdminServiceModel.fromEntity(AdminServiceEntity entity) {
    return AdminServiceModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      serviceType: entity.serviceType,
      isActive: entity.isActive,
    );
  }

  /// Converts the model to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'service_type': serviceType,
      'is_active': isActive,
    };
  }

  /// Creates a request body for updating a service.
  Map<String, dynamic> toUpdateRequest() {
    final request = <String, dynamic>{
      'name': name,
      'service_type': serviceType,
    };
    if (description != null && description!.isNotEmpty) {
      request['description'] = description;
    }
    request['is_active'] = isActive;
    return request;
  }
}
