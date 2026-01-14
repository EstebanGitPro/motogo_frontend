import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/my_branches/data/datasources/my_branches_data_source.dart';
import 'package:motogo_frontend/src/features/my_branches/domain/repositories/my_branches_repository.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';

/// Implementation of [MyBranchesRepository].
///
/// Converts data layer models to domain entities.
class MyBranchesRepositoryImpl implements MyBranchesRepository {
  final MyBranchesDataSource _dataSource;

  MyBranchesRepositoryImpl(this._dataSource);

  @override
  Future<Either<ErrorModel, List<BranchEntity>>> getBranches() async {
    final result = await _dataSource.getBranches();
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }
}
