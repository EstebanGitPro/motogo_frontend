import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/diagnostic/domain/entity/diagnostic_entity.dart';
import 'package:motogo_frontend/src/features/diagnostic/domain/repository/diagnostic_repository.dart';

class ListDiagnosticsUseCase {
  final DiagnosticRepository _repository;

  ListDiagnosticsUseCase(this._repository);

  Future<Either<ErrorModel, List<DiagnosticEntity>>> call({
    required String motorcycleId,
  }) {
    return _repository.listDiagnostics(motorcycleId: motorcycleId);
  }
}
