import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/repositories/branch_repository.dart';

/// Use case for registering a new branch.
///
/// This class encapsulates the business logic for branch registration.
/// It delegates the actual data operation to [BranchRepository].
class RegisterBranchUseCase {
  final BranchRepository branchRepository;

  RegisterBranchUseCase(this.branchRepository);

  /// Executes the use case to register a new branch.
  ///
  /// [branch] The branch entity containing all registration data.
  ///
  /// Returns [Right] with success message on success,
  /// or [Left] with [ErrorModel] on failure.
  Future<Either<ErrorModel, String>> call(BranchEntity branch) async {
    return await branchRepository.registerBranch(branch);
  }
}
