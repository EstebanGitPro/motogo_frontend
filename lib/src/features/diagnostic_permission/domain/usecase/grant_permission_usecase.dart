import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/diagnostic_permission/domain/entity/diagnostic_permission_entity.dart';
import 'package:motogo_frontend/src/features/diagnostic_permission/domain/repository/diagnostic_permission_repository.dart';

class GrantPermissionUseCase {
  final DiagnosticPermissionRepository _repository;

  GrantPermissionUseCase(this._repository);

  Future<Either<ErrorModel, DiagnosticPermissionEntity>> call({
    required String motorcycleId,
    required String branchId,
  }) {
    return _repository.grantPermission(
      motorcycleId: motorcycleId,
      branchId: branchId,
    );
  }
}
