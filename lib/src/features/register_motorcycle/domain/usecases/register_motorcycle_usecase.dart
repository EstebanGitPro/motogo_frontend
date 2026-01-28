import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/entities/motorcycle_entity.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/repositories/motorcycle_repository.dart';

/// Use case for registering a new motorcycle.
///
/// Follows the single responsibility principle - this class only
/// handles the registration of motorcycles.
class RegisterMotorcycleUseCase {
  final MotorcycleRepository _repository;

  RegisterMotorcycleUseCase(this._repository);

  /// Executes the registration of a motorcycle.
  ///
  /// Parameters:
  /// - [licensePlate]: Required. Colombian format plate (e.g., ABC123)
  /// - [year]: Optional. Year of manufacture
  /// - [currentMileage]: Optional. Current odometer reading
  /// - [ownerNotes]: Optional. Personal notes from the owner
  ///
  /// Returns success message on success, or [ErrorModel] on failure.
  Future<Either<ErrorModel, String>> call({
    required String licensePlate,
    int? year,
    int? currentMileage,
    String? ownerNotes,
  }) {
    final motorcycle = MotorcycleEntity(
      licensePlate: licensePlate,
      year: year,
      currentMileage: currentMileage,
      ownerNotes: ownerNotes,
    );

    return _repository.registerMotorcycle(motorcycle);
  }
}
