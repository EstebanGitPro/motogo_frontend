import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/data/datasources/motorcycle_reference_datasource.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/entities/motorcycle_reference_entity.dart';

/// Use case for getting motorcycle references catalog.
class GetMotorcycleReferencesUseCase {
  final MotorcycleReferenceDataSource _dataSource;

  GetMotorcycleReferencesUseCase(this._dataSource);

  /// Executes the get references operation.
  ///
  /// Returns [Right] with list of [MotorcycleReferenceEntity] on success,
  /// or [Left] with [ErrorModel] on failure.
  Future<Either<ErrorModel, List<MotorcycleReferenceEntity>>> call() async {
    final result = await _dataSource.getReferences();
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }
}
