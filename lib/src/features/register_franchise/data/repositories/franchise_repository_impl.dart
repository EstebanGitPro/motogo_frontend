import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register_franchise/data/datasources/register_franchise_data_source.dart';
import 'package:motogo_frontend/src/features/register_franchise/data/models/franchise_model.dart';
import 'package:motogo_frontend/src/features/register_franchise/domain/entities/franchise_entity.dart';
import 'package:motogo_frontend/src/features/register_franchise/domain/repositories/franchise_repository.dart';

/// Implementation of [FranchiseRepository] using [RegisterFranchiseDataSource].
class FranchiseRepositoryImpl implements FranchiseRepository {
  final RegisterFranchiseDataSource _dataSource;

  FranchiseRepositoryImpl(this._dataSource);

  @override
  Future<Either<ErrorModel, FranchiseEntity>> registerFranchise(
    FranchiseEntity franchise,
  ) async {
    final model = FranchiseModel.fromEntity(franchise);
    final result = await _dataSource.registerFranchise(model);

    return result.fold((error) => Left(error), (model) => Right(model));
  }
}
