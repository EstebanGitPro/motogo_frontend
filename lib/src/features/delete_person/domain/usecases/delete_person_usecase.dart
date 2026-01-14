import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/delete_person/domain/repositories/delete_person_repository.dart';

/// Use case for deleting the authenticated user's account.
class DeletePersonUseCase {
  final DeletePersonRepository _repository;

  DeletePersonUseCase(this._repository);

  /// Executes the deletion of the user's account.
  /// Returns success message from backend on success.
  Future<Either<ErrorModel, String>> call() {
    return _repository.deleteAccount();
  }
}
