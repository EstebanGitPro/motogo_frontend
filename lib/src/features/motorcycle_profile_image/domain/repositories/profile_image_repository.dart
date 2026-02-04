import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/motorcycle_profile_image/domain/entities/profile_image_entity.dart';

/// Repository interface for motorcycle profile image operations.
///
/// Defines the contract for profile image CRUD operations.
abstract class ProfileImageRepository {
  /// Updates the profile image of a motorcycle.
  ///
  /// HU36/37: PUT /motorcycles/{id}/profile-image
  Future<Either<ErrorModel, ProfileImageEntity>> updateProfileImage(
    String motorcycleId,
    String imageUrl,
  );

  /// Gets the profile image of a motorcycle.
  ///
  /// HU38: GET /motorcycles/{id}/profile-image
  Future<Either<ErrorModel, ProfileImageEntity>> getProfileImage(
    String motorcycleId,
  );

  /// Deletes the profile image of a motorcycle.
  ///
  /// HU39: DELETE /motorcycles/{id}/profile-image
  Future<Either<ErrorModel, String>> deleteProfileImage(String motorcycleId);
}
