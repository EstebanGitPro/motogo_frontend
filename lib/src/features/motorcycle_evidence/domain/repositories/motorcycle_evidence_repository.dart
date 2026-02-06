import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/domain/entities/motorcycle_evidence_entity.dart';

/// Repository for motorcycle evidence operations.
abstract class MotorcycleEvidenceRepository {
  /// Gets all evidence for a motorcycle.
  Future<Either<ErrorModel, List<MotorcycleEvidenceEntity>>> getEvidence({
    required String motorcycleId,
  });

  /// Creates evidence for a motorcycle.
  Future<Either<ErrorModel, MotorcycleEvidenceEntity>> createEvidence({
    required String motorcycleId,
    required String imageUrl,
    String? angle,
    String? description,
  });

  /// Deletes evidence for a motorcycle.
  Future<Either<ErrorModel, String>> deleteEvidence({
    required String motorcycleId,
    required String evidenceId,
  });
}
