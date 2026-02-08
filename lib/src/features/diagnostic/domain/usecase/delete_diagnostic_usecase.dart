import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/diagnostic/domain/repository/diagnostic_repository.dart';

class DeleteDiagnosticUseCase {
  final DiagnosticRepository _repository;

  DeleteDiagnosticUseCase(this._repository);

  Future<Either<ErrorModel, String>> call({
    required String motorcycleId,
    required String diagnosticId,
  }) {
    return _repository.deleteDiagnostic(
      motorcycleId: motorcycleId,
      diagnosticId: diagnosticId,
    );
  }
}
