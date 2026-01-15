import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/manage_franchise/data/datasources/franchise_data_source.dart';
import 'package:motogo_frontend/src/features/register_franchise/data/models/franchise_model.dart';
import 'package:motogo_frontend/src/features/register_franchise/domain/entities/franchise_entity.dart';

/// Use case for getting a franchise by ID.
class GetFranchiseUseCase {
  final FranchiseDataSource _dataSource;

  GetFranchiseUseCase(this._dataSource);

  Future<Either<ErrorModel, FranchiseEntity>> call(String franchiseId) async {
    return _dataSource.getFranchise(franchiseId);
  }
}

/// Use case for listing all user's franchises.
class ListFranchisesUseCase {
  final FranchiseDataSource _dataSource;

  ListFranchisesUseCase(this._dataSource);

  Future<Either<ErrorModel, List<FranchiseEntity>>> call() async {
    final result = await _dataSource.listFranchises();
    return result.fold(
      (error) => Left(error),
      (franchises) => Right(franchises.cast<FranchiseEntity>()),
    );
  }
}

/// Use case for updating a franchise.
class UpdateFranchiseUseCase {
  final FranchiseDataSource _dataSource;

  UpdateFranchiseUseCase(this._dataSource);

  Future<Either<ErrorModel, FranchiseEntity>> call(
    String franchiseId,
    FranchiseEntity franchise,
  ) async {
    final model = FranchiseModel.fromEntity(franchise);
    return _dataSource.updateFranchise(franchiseId, model);
  }
}

/// Use case for deleting a franchise.
class DeleteFranchiseUseCase {
  final FranchiseDataSource _dataSource;

  DeleteFranchiseUseCase(this._dataSource);

  Future<Either<ErrorModel, String>> call(String franchiseId) async {
    return _dataSource.deleteFranchise(franchiseId);
  }
}

/// Use case for linking a branch to a franchise.
class LinkBranchToFranchiseUseCase {
  final FranchiseDataSource _dataSource;

  LinkBranchToFranchiseUseCase(this._dataSource);

  Future<Either<ErrorModel, String>> call(
    String branchId,
    String franchiseId,
  ) async {
    return _dataSource.linkBranch(branchId, franchiseId);
  }
}

/// Use case for unlinking a branch from its franchise.
class UnlinkBranchFromFranchiseUseCase {
  final FranchiseDataSource _dataSource;

  UnlinkBranchFromFranchiseUseCase(this._dataSource);

  Future<Either<ErrorModel, String>> call(
    String branchId,
    String franchiseId,
  ) async {
    return _dataSource.unlinkBranch(branchId, franchiseId);
  }
}
