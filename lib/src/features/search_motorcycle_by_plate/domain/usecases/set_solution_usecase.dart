import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/repositories/search_motorcycle_repository.dart';

/// Use case for setting the diagnostic solution (workshop representative).
///
/// Calls PATCH /diagnostics/:id/solution via the repository.
class SetSolutionUseCase {
  final SearchMotorcycleRepository _repository;

  SetSolutionUseCase(this._repository);

  /// Executes the use case to set a diagnostic solution.
  ///
  /// [diagnosticId] - The diagnostic ID to update.
  /// [solution] - The proposed solution text.
  ///
  /// Returns [Right] with success message on success,
  /// or [Left] with [ErrorModel] on failure.
  Future<Either<ErrorModel, String>> call({
    required String diagnosticId,
    required String solution,
  }) {
    return _repository.setSolution(
      diagnosticId: diagnosticId,
      solution: solution,
    );
  }
}
