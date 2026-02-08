import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/diagnostic_permission/domain/entity/diagnostic_permission_entity.dart';

/// Repository interface for diagnostic permission operations.
abstract class DiagnosticPermissionRepository {
  /// Grants a branch permission to access a motorcycle.
  Future<Either<ErrorModel, DiagnosticPermissionEntity>> grantPermission({
    required String motorcycleId,
    required String branchId,
  });

  /// Lists all granted permissions for a motorcycle.
  Future<Either<ErrorModel, List<DiagnosticPermissionEntity>>> listPermissions({
    required String motorcycleId,
  });

  /// Revokes a branch's permission.
  Future<Either<ErrorModel, String>> revokePermission({
    required String motorcycleId,
    required String branchId,
  });
}
