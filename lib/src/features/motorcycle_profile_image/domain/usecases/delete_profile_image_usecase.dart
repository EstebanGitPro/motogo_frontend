import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/motorcycle_profile_image/domain/repositories/profile_image_repository.dart';

/// Use case for deleting motorcycle profile image.
///
/// HU39: DELETE /motorcycles/{id}/profile-image
class DeleteProfileImageUseCase {
  final ProfileImageRepository _repository;

  DeleteProfileImageUseCase(this._repository);

  /// Deletes the profile image for the specified motorcycle.
  ///
  /// Parameters:
  /// - [motorcycleId]: ID of the motorcycle
  ///
  /// Returns success message on success, or [ErrorModel] on failure.
  Future<Either<ErrorModel, String>> call({required String motorcycleId}) {
    return _repository.deleteProfileImage(motorcycleId);
  }
}
