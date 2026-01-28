import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/entities/motorcycle_entity.dart';

/// Repository interface for motorcycle operations.
///
/// Defines the contract for motorcycle CRUD operations following
/// clean architecture principles.
abstract class MotorcycleRepository {
  /// Registers a new motorcycle for the current user.
  ///
  /// Returns a success message from the backend on success,
  /// or an [ErrorModel] on failure.
  Future<Either<ErrorModel, String>> registerMotorcycle(
    MotorcycleEntity motorcycle,
  );
}
