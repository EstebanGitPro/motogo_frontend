import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/diagnostic_permission/domain/entity/diagnostic_permission_entity.dart';
import 'package:motogo_frontend/src/features/diagnostic_permission/domain/repository/diagnostic_permission_repository.dart';

class ListPermissionsUseCase {
  final DiagnosticPermissionRepository _repository;

  ListPermissionsUseCase(this._repository);

  Future<Either<ErrorModel, List<DiagnosticPermissionEntity>>> call({
    required String motorcycleId,
  }) {
    return _repository.listPermissions(motorcycleId: motorcycleId);
  }
}
