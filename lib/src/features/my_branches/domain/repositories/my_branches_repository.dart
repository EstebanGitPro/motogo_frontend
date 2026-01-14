import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';

/// Abstract repository interface for branch listing operations.
///
/// This interface defines the contract for fetching the user's branches.
/// Implemented by [MyBranchesRepositoryImpl] in the data layer.
abstract class MyBranchesRepository {
  /// Gets the list of branches for the authenticated user.
  ///
  /// Returns [Right] with a list of [BranchEntity] on success,
  /// or [Left] with [ErrorModel] on failure.
  Future<Either<ErrorModel, List<BranchEntity>>> getBranches();
}
