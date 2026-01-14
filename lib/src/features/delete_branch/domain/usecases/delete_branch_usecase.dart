import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/delete_branch/domain/repositories/delete_branch_repository.dart';

/// Use case for deleting a branch.
///
/// Delegates to [DeleteBranchRepository.deleteBranch].
class DeleteBranchUseCase {
  final DeleteBranchRepository repository;

  DeleteBranchUseCase(this.repository);

  /// Executes the delete branch operation.
  ///
  /// Returns [Right] with success message on success,
  /// or [Left] with [ErrorModel] on failure.
  Future<Either<ErrorModel, String>> call(String id) async {
    return await repository.deleteBranch(id);
  }
}
