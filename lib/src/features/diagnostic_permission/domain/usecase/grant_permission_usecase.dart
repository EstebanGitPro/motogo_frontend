import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/diagnostic_permission/domain/entity/permission_grant_result.dart';
import 'package:motogo_frontend/src/features/diagnostic_permission/domain/repository/diagnostic_permission_repository.dart';

class GrantPermissionUseCase {
  final DiagnosticPermissionRepository _repository;

  GrantPermissionUseCase(this._repository);

  Future<Either<ErrorModel, PermissionGrantResult>> call({
    required String motorcycleId,
    required String branchId,
    required bool active,
  }) {
    return _repository.grantPermission(
      motorcycleId: motorcycleId,
      branchId: branchId,
      active: active,
    );
  }
}
