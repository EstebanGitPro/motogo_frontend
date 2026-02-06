import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/domain/repositories/motorcycle_evidence_repository.dart';

/// Use case for deleting motorcycle evidence.
class DeleteEvidenceUseCase {
  final MotorcycleEvidenceRepository _repository;

  DeleteEvidenceUseCase({required MotorcycleEvidenceRepository repository})
    : _repository = repository;

  /// Deletes evidence by ID.
  Future<Either<ErrorModel, String>> call({
    required String motorcycleId,
    required String evidenceId,
  }) {
    return _repository.deleteEvidence(
      motorcycleId: motorcycleId,
      evidenceId: evidenceId,
    );
  }
}
