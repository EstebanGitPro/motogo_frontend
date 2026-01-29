import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/entities/motorcycle_entity.dart';

/// Abstract repository interface for motorcycle listing operations.
///
/// This interface defines the contract for fetching the user's motorcycles.
/// Implemented by [MyMotorcyclesRepositoryImpl] in the data layer.
abstract class MyMotorcyclesRepository {
  /// Gets the list of motorcycles for the authenticated user.
  ///
  /// Returns [Right] with a list of [MotorcycleEntity] on success,
  /// or [Left] with [ErrorModel] on failure.
  Future<Either<ErrorModel, List<MotorcycleEntity>>> getMotorcycles();
}
