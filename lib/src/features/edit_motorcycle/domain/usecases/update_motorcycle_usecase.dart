import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/edit_motorcycle/data/datasources/edit_motorcycle_datasource.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/data/models/motorcycle_model.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/entities/motorcycle_entity.dart';

/// Use case for updating a motorcycle.
///
/// Handles conversion from entity to model and delegates to data source.
class UpdateMotorcycleUseCase {
  final EditMotorcycleDataSource _dataSource;

  UpdateMotorcycleUseCase(this._dataSource);

  /// Executes the update motorcycle operation.
  ///
  /// Returns [Right] with success message on success,
  /// or [Left] with [ErrorModel] on failure.
  Future<Either<ErrorModel, String>> call(
    String id,
    MotorcycleEntity motorcycle,
  ) {
    final model = MotorcycleModel.fromEntity(motorcycle);
    return _dataSource.updateMotorcycle(id, model);
  }
}
