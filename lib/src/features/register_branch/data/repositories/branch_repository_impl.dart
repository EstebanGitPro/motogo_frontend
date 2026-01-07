import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register_branch/data/datasources/register_branch_data_source.dart';
import 'package:motogo_frontend/src/features/register_branch/data/models/branch_model.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/repositories/branch_repository.dart';

/// Implementation of [BranchRepository] using [RegisterBranchDataSource].
class BranchRepositoryImpl implements BranchRepository {
  final RegisterBranchDataSource dataSource;

  BranchRepositoryImpl(this.dataSource);

  @override
  Future<Either<ErrorModel, String>> registerBranch(BranchEntity branch) async {
    final model = BranchModel.fromEntity(branch);
    return await dataSource.registerBranch(model);
  }
}
