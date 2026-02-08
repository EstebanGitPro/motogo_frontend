import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/diagnostic/domain/entity/diagnostic_entity.dart';
import 'package:motogo_frontend/src/features/diagnostic/domain/repository/diagnostic_repository.dart';

class CreateDiagnosticUseCase {
  final DiagnosticRepository _repository;

  CreateDiagnosticUseCase(this._repository);

  Future<Either<ErrorModel, DiagnosticEntity>> call({
    required String motorcycleId,
    required String problemDescription,
    String? branchId,
    String? serviceType,
  }) {
    return _repository.createDiagnostic(
      motorcycleId: motorcycleId,
      problemDescription: problemDescription,
      branchId: branchId,
      serviceType: serviceType,
    );
  }
}
