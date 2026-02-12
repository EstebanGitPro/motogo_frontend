import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/diagnostic/domain/repository/diagnostic_repository.dart';

class UpdateDiagnosticUseCase {
  final DiagnosticRepository _repository;

  UpdateDiagnosticUseCase(this._repository);

  Future<Either<ErrorModel, String>> call({
    required String motorcycleId,
    required String diagnosticId,
    required Map<String, dynamic> data,
  }) {
    return _repository.updateDiagnostic(
      motorcycleId: motorcycleId,
      diagnosticId: diagnosticId,
      data: data,
    );
  }
}
