import 'package:equatable/equatable.dart';

/// Entity representing a service from the global catalog.
///
/// This entity is used in the admin context for managing the service catalog.
class AdminServiceEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String serviceType;
  final bool isActive;

  const AdminServiceEntity({
    required this.id,
    required this.name,
    this.description,
    required this.serviceType,
    required this.isActive,
  });

  /// Creates a copy with specified values overridden.
  AdminServiceEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? serviceType,
    bool? isActive,
  }) {
    return AdminServiceEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      serviceType: serviceType ?? this.serviceType,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, description, serviceType, isActive];
}
