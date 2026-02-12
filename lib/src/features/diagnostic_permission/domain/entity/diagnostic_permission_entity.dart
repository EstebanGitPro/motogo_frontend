import 'package:equatable/equatable.dart';

/// Entity representing a diagnostic permission granted to a branch.
class DiagnosticPermissionEntity extends Equatable {
  final String id;
  final String motorcycleId;
  final String branchId;
  final String? branchName;
  final bool active;
  final DateTime grantedAt;

  const DiagnosticPermissionEntity({
    required this.id,
    required this.motorcycleId,
    required this.branchId,
    this.branchName,
    this.active = true,
    required this.grantedAt,
  });

  @override
  List<Object?> get props => [
    id,
    motorcycleId,
    branchId,
    branchName,
    active,
    grantedAt,
  ];
}
