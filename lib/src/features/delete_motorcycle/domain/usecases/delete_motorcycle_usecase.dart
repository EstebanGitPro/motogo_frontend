import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/delete_motorcycle/domain/repositories/delete_motorcycle_repository.dart';

/// Use case for deleting a motorcycle.
///
/// Delegates to [DeleteMotorcycleRepository.deleteMotorcycle].
class DeleteMotorcycleUseCase {
  final DeleteMotorcycleRepository repository;

  DeleteMotorcycleUseCase(this.repository);

  /// Executes the delete motorcycle operation.
  ///
  /// Returns [Right] with success message on success,
  /// or [Left] with [ErrorModel] on failure.
  Future<Either<ErrorModel, String>> call(String id) async {
    return await repository.deleteMotorcycle(id);
  }
}
