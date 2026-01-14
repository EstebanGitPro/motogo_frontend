import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/my_branches/domain/repositories/my_branches_repository.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';

/// Use case for fetching the user's branches.
///
/// Follows the Single Responsibility principle by encapsulating
/// the branch retrieval business logic.
class GetBranchesUseCase {
  final MyBranchesRepository _repository;

  GetBranchesUseCase(this._repository);

  /// Executes the use case to get branches.
  ///
  /// Returns [Right] with a list of [BranchEntity] on success,
  /// or [Left] with [ErrorModel] on failure.
  Future<Either<ErrorModel, List<BranchEntity>>> call() {
    return _repository.getBranches();
  }
}
