import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/my_motorcycles/data/datasources/my_motorcycles_datasource.dart';
import 'package:motogo_frontend/src/features/my_motorcycles/domain/repositories/my_motorcycles_repository.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/entities/motorcycle_entity.dart';

/// Implementation of [MyMotorcyclesRepository].
///
/// Converts data layer models to domain entities.
class MyMotorcyclesRepositoryImpl implements MyMotorcyclesRepository {
  final MyMotorcyclesDataSource _dataSource;

  MyMotorcyclesRepositoryImpl(this._dataSource);

  @override
  Future<Either<ErrorModel, List<MotorcycleEntity>>> getMotorcycles() async {
    final result = await _dataSource.getMotorcycles();
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }
}
