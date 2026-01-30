import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/entities/motorcycle_detail_entity.dart';

/// Repository interface for searching motorcycles.
///
/// Part of the domain layer for the search motorcycle by plate feature.
abstract class SearchMotorcycleRepository {
  /// Searches for a motorcycle by its license plate.
  ///
  /// Returns [Right] with [MotorcycleDetailEntity] on success,
  /// or [Left] with [ErrorModel] on failure.
  Future<Either<ErrorModel, MotorcycleDetailEntity>> searchByPlate(
    String plate,
  );
}
