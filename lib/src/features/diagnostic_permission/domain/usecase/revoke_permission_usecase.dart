import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/diagnostic_permission/domain/repository/diagnostic_permission_repository.dart';

class RevokePermissionUseCase {
  final DiagnosticPermissionRepository _repository;

  RevokePermissionUseCase(this._repository);

  Future<Either<ErrorModel, String>> call({
    required String motorcycleId,
    required String branchId,
  }) {
    return _repository.revokePermission(
      motorcycleId: motorcycleId,
      branchId: branchId,
    );
  }
}
