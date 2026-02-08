import 'package:motogo_frontend/src/features/diagnostic_permission/domain/entity/diagnostic_permission_entity.dart';

/// Model for diagnostic permission API responses.
class DiagnosticPermissionModel {
  final String id;
  final String motorcycleId;
  final String branchId;
  final String? branchName;
  final String grantedAt;

  const DiagnosticPermissionModel({
    required this.id,
    required this.motorcycleId,
    required this.branchId,
    this.branchName,
    required this.grantedAt,
  });

  factory DiagnosticPermissionModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final source = data ?? json;

    return DiagnosticPermissionModel(
      id: source['id'] as String? ?? '',
      motorcycleId: source['motorcycle_id'] as String? ?? '',
      branchId: source['branch_id'] as String? ?? '',
      branchName: source['branch_name'] as String?,
      grantedAt: source['granted_at'] as String? ?? '',
    );
  }

  factory DiagnosticPermissionModel.fromDataJson(Map<String, dynamic> json) {
    return DiagnosticPermissionModel(
      id: json['id'] as String? ?? '',
      motorcycleId: json['motorcycle_id'] as String? ?? '',
      branchId: json['branch_id'] as String? ?? '',
      branchName: json['branch_name'] as String?,
      grantedAt: json['granted_at'] as String? ?? '',
    );
  }

  DiagnosticPermissionEntity toEntity() {
    return DiagnosticPermissionEntity(
      id: id,
      motorcycleId: motorcycleId,
      branchId: branchId,
      branchName: branchName,
      grantedAt: DateTime.tryParse(grantedAt) ?? DateTime.now(),
    );
  }
}
