import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/motorcycle_profile_image/domain/entities/profile_image_entity.dart';
import 'package:motogo_frontend/src/features/motorcycle_profile_image/domain/repositories/profile_image_repository.dart';

/// Use case for getting motorcycle profile image.
///
/// HU38: GET /motorcycles/{id}/profile-image
class GetProfileImageUseCase {
  final ProfileImageRepository _repository;

  GetProfileImageUseCase(this._repository);

  /// Gets the profile image for the specified motorcycle.
  ///
  /// Parameters:
  /// - [motorcycleId]: ID of the motorcycle to query
  ///
  /// Returns profile image entity on success, or [ErrorModel] on failure.
  Future<Either<ErrorModel, ProfileImageEntity>> call({
    required String motorcycleId,
  }) {
    return _repository.getProfileImage(motorcycleId);
  }
}
