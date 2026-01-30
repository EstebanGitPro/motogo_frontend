import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/data/datasources/search_motorcycle_datasource.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/entities/motorcycle_detail_entity.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/repositories/search_motorcycle_repository.dart';

/// Implementation of [SearchMotorcycleRepository].
///
/// Connects the domain layer to the data layer.
class SearchMotorcycleRepositoryImpl implements SearchMotorcycleRepository {
  final SearchMotorcycleDataSource _dataSource;

  SearchMotorcycleRepositoryImpl(this._dataSource);

  @override
  Future<Either<ErrorModel, MotorcycleDetailEntity>> searchByPlate(
    String plate,
  ) async {
    final result = await _dataSource.searchByPlate(plate);
    return result.map((model) => model.toEntity());
  }
}
