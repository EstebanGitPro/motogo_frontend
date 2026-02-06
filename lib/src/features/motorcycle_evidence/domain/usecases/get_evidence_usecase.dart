import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/domain/entities/motorcycle_evidence_entity.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/domain/repositories/motorcycle_evidence_repository.dart';

/// UseCase for getting all evidence for a motorcycle.
class GetEvidenceUseCase {
  final MotorcycleEvidenceRepository _repository;

  GetEvidenceUseCase(this._repository);

  Future<Either<ErrorModel, List<MotorcycleEvidenceEntity>>> call({
    required String motorcycleId,
  }) {
    return _repository.getEvidence(motorcycleId: motorcycleId);
  }
}
