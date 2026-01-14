import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/repositories/branch_repository.dart';

/// Use case for updating an existing branch.
///
/// Delegates to [BranchRepository.updateBranch].
class UpdateBranchUseCase {
  final BranchRepository repository;

  UpdateBranchUseCase(this.repository);

  /// Executes the update branch operation.
  ///
  /// Returns [Right] with the updated [BranchEntity] on success,
  /// or [Left] with [ErrorModel] on failure.
  Future<Either<ErrorModel, BranchEntity>> call(
    String id,
    BranchEntity branch,
  ) async {
    return await repository.updateBranch(id, branch);
  }
}
