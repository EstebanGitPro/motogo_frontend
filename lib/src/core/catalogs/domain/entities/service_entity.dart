import 'package:equatable/equatable.dart';

/// Entity representing a service from the global catalog.
///
/// This is the base service from the catalog, without branch-specific fields.
class ServiceEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String serviceType;

  const ServiceEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.serviceType,
  });

  @override
  List<Object?> get props => [id, name, description, serviceType];
}
