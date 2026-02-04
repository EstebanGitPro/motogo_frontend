import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/motorcycle_profile_image/domain/entities/profile_image_entity.dart';
import 'package:motogo_frontend/src/features/motorcycle_profile_image/domain/repositories/profile_image_repository.dart';

/// Use case for updating motorcycle profile image.
///
/// HU36/37: PUT /motorcycles/{id}/profile-image
class UpdateProfileImageUseCase {
  final ProfileImageRepository _repository;

  UpdateProfileImageUseCase(this._repository);

  /// Updates the profile image for the specified motorcycle.
  ///
  /// Parameters:
  /// - [motorcycleId]: ID of the motorcycle to update
  /// - [imageUrl]: URL of the new profile image (Firebase Storage)
  ///
  /// Returns profile image entity on success, or [ErrorModel] on failure.
  Future<Either<ErrorModel, ProfileImageEntity>> call({
    required String motorcycleId,
    required String imageUrl,
  }) {
    return _repository.updateProfileImage(motorcycleId, imageUrl);
  }
}
