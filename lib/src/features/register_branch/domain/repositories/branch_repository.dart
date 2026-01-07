import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';

/// Abstract repository interface for branch operations.
///
/// This interface defines the contract for branch-related data operations.
/// Implemented by [BranchRepositoryImpl] in the data layer.
abstract class BranchRepository {
  /// Registers a new branch in the system.
  ///
  /// Returns [Right] with the success message from backend on success,
  /// or [Left] with [ErrorModel] on failure.
  Future<Either<ErrorModel, String>> registerBranch(BranchEntity branch);
}
