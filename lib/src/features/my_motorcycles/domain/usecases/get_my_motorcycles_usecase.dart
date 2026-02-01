import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/my_motorcycles/domain/repositories/my_motorcycles_repository.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/entities/motorcycle_entity.dart';

/// Use case for fetching the user's motorcycles.
///
/// Follows the Single Responsibility principle by encapsulating
/// the motorcycle retrieval business logic.
class GetMyMotorcyclesUseCase {
  final MyMotorcyclesRepository _repository;

  GetMyMotorcyclesUseCase(this._repository);

  /// Executes the use case to get motorcycles.
  ///
  /// Returns [Right] with a list of [MotorcycleEntity] on success,
  /// or [Left] with [ErrorModel] on failure.
  Future<Either<ErrorModel, List<MotorcycleEntity>>> call() {
    return _repository.getMotorcycles();
  }
}
