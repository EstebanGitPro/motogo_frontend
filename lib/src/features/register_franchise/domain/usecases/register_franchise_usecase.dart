import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register_franchise/domain/entities/franchise_entity.dart';
import 'package:motogo_frontend/src/features/register_franchise/domain/repositories/franchise_repository.dart';

/// Use case for registering a new franchise.
class RegisterFranchiseUseCase {
  final FranchiseRepository _repository;

  RegisterFranchiseUseCase(this._repository);

  /// Registers a franchise with the provided entity data.
  ///
  /// Validates that at least one branch is selected before proceeding.
  /// Returns a Record with the created [FranchiseEntity] and the backend
  /// success message.
  Future<Either<ErrorModel, (FranchiseEntity, String)>> call(
    FranchiseEntity franchise,
  ) async {
    // Validate at least one branch is selected
    if (franchise.branchIds.isEmpty) {
      return Left(ErrorModel(message: 'Debes seleccionar al menos una sede'));
    }

    return _repository.registerFranchise(franchise);
  }
}
