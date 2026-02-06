import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/data/datasources/motorcycle_evidence_datasource.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/domain/entities/motorcycle_evidence_entity.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/domain/repositories/motorcycle_evidence_repository.dart';

class MotorcycleEvidenceRepositoryImpl implements MotorcycleEvidenceRepository {
  final MotorcycleEvidenceDataSource _dataSource;

  MotorcycleEvidenceRepositoryImpl(this._dataSource);

  @override
  Future<Either<ErrorModel, List<MotorcycleEvidenceEntity>>> getEvidence({
    required String motorcycleId,
  }) async {
    final result = await _dataSource.getEvidence(motorcycleId: motorcycleId);

    return result.fold(
      (error) => Left(error),
      (models) => Right(models.map((m) => m.toEntity()).toList()),
    );
  }

  @override
  Future<Either<ErrorModel, MotorcycleEvidenceEntity>> createEvidence({
    required String motorcycleId,
    required String imageUrl,
    String? angle,
    String? description,
  }) async {
    final result = await _dataSource.createEvidence(
      motorcycleId: motorcycleId,
      imageUrl: imageUrl,
      angle: angle,
      description: description,
    );

    return result.fold(
      (error) => Left(error),
      (response) => Right(response.model.toEntity()),
    );
  }

  @override
  Future<Either<ErrorModel, String>> deleteEvidence({
    required String motorcycleId,
    required String evidenceId,
  }) async {
    return _dataSource.deleteEvidence(
      motorcycleId: motorcycleId,
      evidenceId: evidenceId,
    );
  }
}
