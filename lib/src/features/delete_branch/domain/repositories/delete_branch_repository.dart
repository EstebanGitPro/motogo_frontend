import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/delete_branch/data/datasources/delete_branch_data_source.dart';

/// Repository interface for branch deletion.
abstract class DeleteBranchRepository {
  /// Deletes a branch by ID.
  ///
  /// Returns [Right] with success message on success,
  /// or [Left] with [ErrorModel] on failure.
  Future<Either<ErrorModel, String>> deleteBranch(String id);
}

/// Implementation of [DeleteBranchRepository].
class DeleteBranchRepositoryImpl implements DeleteBranchRepository {
  final DeleteBranchDataSource dataSource;

  DeleteBranchRepositoryImpl(this.dataSource);

  @override
  Future<Either<ErrorModel, String>> deleteBranch(String id) async {
    return await dataSource.deleteBranch(id);
  }
}
