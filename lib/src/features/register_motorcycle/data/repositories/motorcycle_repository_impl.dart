import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/data/datasources/motorcycle_datasource.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/data/models/motorcycle_model.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/entities/motorcycle_entity.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/repositories/motorcycle_repository.dart';

/// Implementation of the motorcycle repository.
///
/// Bridges the domain layer with the data layer by converting
/// entities to models and forwarding requests to the data source.
class MotorcycleRepositoryImpl implements MotorcycleRepository {
  final MotorcycleDataSource _dataSource;

  MotorcycleRepositoryImpl(this._dataSource);

  @override
  Future<Either<ErrorModel, String>> registerMotorcycle(
    MotorcycleEntity motorcycle,
  ) async {
    final model = MotorcycleModel.fromEntity(motorcycle);
    return _dataSource.registerMotorcycle(model);
  }
}
