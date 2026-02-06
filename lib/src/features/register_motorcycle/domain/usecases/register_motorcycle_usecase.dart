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
  /// - [licensePlate]: Required. Colombian format plate (e.g., ABC12D or ABC123)
  /// - [referenceId]: Optional. ID of the motorcycle reference from catalog
  /// - [year]: Optional. Year of manufacture
  /// - [currentMileage]: Optional. Current odometer reading
  /// - [ownerNotes]: Optional. Personal notes from the owner
  /// - [profileImageUrl]: Optional. URL of the motorcycle's profile image
  ///
  /// Returns success message on success, or [ErrorModel] on failure.
  Future<Either<ErrorModel, String>> call({
    required String licensePlate,
    String? referenceId,
    int? year,
    int? currentMileage,
    String? ownerNotes,
    String? profileImageUrl,
  }) {
    final motorcycle = MotorcycleEntity(
      licensePlate: licensePlate,
      referenceId: referenceId,
      year: year,
      currentMileage: currentMileage,
      ownerNotes: ownerNotes,
      profileImageUrl: profileImageUrl,
    );

    return _repository.registerMotorcycle(motorcycle);
  }
}
