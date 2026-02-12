import 'package:equatable/equatable.dart';
import 'package:motogo_frontend/src/features/diagnostic_permission/domain/entity/diagnostic_permission_entity.dart';

/// Result container for permission grant operations.
///
/// Carries both the permission entity and the authoritative backend message.
class PermissionGrantResult extends Equatable {
  final DiagnosticPermissionEntity permission;
  final String message;

  const PermissionGrantResult({
    required this.permission,
    required this.message,
  });

  @override
  List<Object?> get props => [permission, message];
}
