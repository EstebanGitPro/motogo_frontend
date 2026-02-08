import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/diagnostic_permission/data/datasource/diagnostic_permission_datasource.dart';
import 'package:motogo_frontend/src/features/diagnostic_permission/domain/entity/diagnostic_permission_entity.dart';
import 'package:motogo_frontend/src/features/diagnostic_permission/domain/repository/diagnostic_permission_repository.dart';

class DiagnosticPermissionRepositoryImpl
    implements DiagnosticPermissionRepository {
  final DiagnosticPermissionDataSource _dataSource;

  DiagnosticPermissionRepositoryImpl(this._dataSource);

  @override
  Future<Either<ErrorModel, DiagnosticPermissionEntity>> grantPermission({
    required String motorcycleId,
    required String branchId,
  }) async {
    final result = await _dataSource.grantPermission(
      motorcycleId: motorcycleId,
      branchId: branchId,
    );

    return result.fold(
      (error) => Left(error),
      (response) => Right(response.model.toEntity()),
    );
  }

  @override
  Future<Either<ErrorModel, List<DiagnosticPermissionEntity>>> listPermissions({
    required String motorcycleId,
  }) async {
    final result = await _dataSource.listPermissions(
      motorcycleId: motorcycleId,
    );

    return result.fold(
      (error) => Left(error),
      (models) => Right(models.map((m) => m.toEntity()).toList()),
    );
  }

  @override
  Future<Either<ErrorModel, String>> revokePermission({
    required String motorcycleId,
    required String branchId,
  }) {
    return _dataSource.revokePermission(
      motorcycleId: motorcycleId,
      branchId: branchId,
    );
  }
}
