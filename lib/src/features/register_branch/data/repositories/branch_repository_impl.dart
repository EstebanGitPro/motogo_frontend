import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/edit_branch/data/datasources/edit_branch_data_source.dart';
import 'package:motogo_frontend/src/features/register_branch/data/datasources/register_branch_data_source.dart';
import 'package:motogo_frontend/src/features/register_branch/data/models/branch_model.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/repositories/branch_repository.dart';

/// Implementation of [BranchRepository] using data sources.
class BranchRepositoryImpl implements BranchRepository {
  final RegisterBranchDataSource _registerDataSource;
  final EditBranchDataSource _editDataSource;

  BranchRepositoryImpl(this._registerDataSource, this._editDataSource);

  @override
  Future<Either<ErrorModel, String>> registerBranch(BranchEntity branch) async {
    final model = BranchModel.fromEntity(branch);
    return await _registerDataSource.registerBranch(model);
  }

  @override
  Future<Either<ErrorModel, (BranchEntity, String)>> updateBranch(
    String id,
    BranchEntity branch,
  ) async {
    final model = BranchModel.fromEntity(branch);
    return await _editDataSource.updateBranch(id, model);
  }
}
