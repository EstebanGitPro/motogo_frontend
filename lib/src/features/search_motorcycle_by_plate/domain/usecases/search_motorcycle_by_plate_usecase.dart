import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/entities/motorcycle_detail_entity.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/repositories/search_motorcycle_repository.dart';

/// Use case for searching a motorcycle by its license plate.
///
/// Follows the Single Responsibility principle by encapsulating
/// the motorcycle lookup business logic (HU47).
class SearchMotorcycleByPlateUseCase {
  final SearchMotorcycleRepository _repository;

  SearchMotorcycleByPlateUseCase(this._repository);

  /// Executes the use case to search for a motorcycle.
  ///
  /// [plate] - The license plate to search for.
  ///
  /// Returns [Right] with [MotorcycleDetailEntity] on success,
  /// or [Left] with [ErrorModel] on failure.
  Future<Either<ErrorModel, MotorcycleDetailEntity>> call(String plate) {
    return _repository.searchByPlate(plate);
  }
}
