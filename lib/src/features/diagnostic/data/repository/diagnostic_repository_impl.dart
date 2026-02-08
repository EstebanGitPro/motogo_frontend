import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/diagnostic/data/datasource/diagnostic_datasource.dart';
import 'package:motogo_frontend/src/features/diagnostic/domain/entity/diagnostic_entity.dart';
import 'package:motogo_frontend/src/features/diagnostic/domain/repository/diagnostic_repository.dart';

class DiagnosticRepositoryImpl implements DiagnosticRepository {
  final DiagnosticDataSource _dataSource;

  DiagnosticRepositoryImpl(this._dataSource);

  @override
  Future<Either<ErrorModel, DiagnosticEntity>> createDiagnostic({
    required String motorcycleId,
    required String problemDescription,
    String? branchId,
    String? serviceType,
  }) async {
    final result = await _dataSource.createDiagnostic(
      motorcycleId: motorcycleId,
      problemDescription: problemDescription,
      branchId: branchId,
      serviceType: serviceType,
    );

    return result.fold(
      (error) => Left(error),
      (response) => Right(response.model.toEntity()),
    );
  }

  @override
  Future<Either<ErrorModel, List<DiagnosticEntity>>> listDiagnostics({
    required String motorcycleId,
  }) async {
    final result = await _dataSource.listDiagnostics(
      motorcycleId: motorcycleId,
    );

    return result.fold(
      (error) => Left(error),
      (models) => Right(models.map((m) => m.toEntity()).toList()),
    );
  }

  @override
  Future<Either<ErrorModel, DiagnosticEntity>> getDiagnostic({
    required String motorcycleId,
    required String diagnosticId,
  }) async {
    final result = await _dataSource.getDiagnostic(
      motorcycleId: motorcycleId,
      diagnosticId: diagnosticId,
    );

    return result.fold(
      (error) => Left(error),
      (model) => Right(model.toEntity()),
    );
  }

  @override
  Future<Either<ErrorModel, String>> updateDiagnostic({
    required String motorcycleId,
    required String diagnosticId,
    required Map<String, dynamic> data,
  }) {
    return _dataSource.updateDiagnostic(
      motorcycleId: motorcycleId,
      diagnosticId: diagnosticId,
      data: data,
    );
  }

  @override
  Future<Either<ErrorModel, String>> deleteDiagnostic({
    required String motorcycleId,
    required String diagnosticId,
  }) {
    return _dataSource.deleteDiagnostic(
      motorcycleId: motorcycleId,
      diagnosticId: diagnosticId,
    );
  }
}
