import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register_franchise/domain/entities/franchise_entity.dart';

/// Repository interface for franchise operations.
abstract class FranchiseRepository {
  /// Registers a new franchise with the given entity data.
  ///
  /// Returns the created [FranchiseEntity] on success, or an [ErrorModel] on failure.
  Future<Either<ErrorModel, FranchiseEntity>> registerFranchise(
    FranchiseEntity franchise,
  );
}
