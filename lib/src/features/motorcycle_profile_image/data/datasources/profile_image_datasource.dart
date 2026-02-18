import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';
import 'package:motogo_frontend/src/features/motorcycle_profile_image/data/models/profile_image_model.dart';

/// Response wrapper that includes both the model and backend message.
class ProfileImageResponse {
  final ProfileImageModel model;
  final String message;

  const ProfileImageResponse({required this.model, required this.message});
}

/// DataSource for motorcycle profile image operations.
///
/// Uses DioClient with automatic token refresh.
abstract class ProfileImageDataSource {
  /// Updates the profile image of a motorcycle.
  ///
  /// HU36/37: PUT /motorcycles/{id}/profile-image
  /// Returns [ProfileImageResponse] with model and backend message.
  Future<Either<ErrorModel, ProfileImageResponse>> updateProfileImage(
    String motorcycleId,
    String imageUrl,
  );

  /// Gets the profile image of a motorcycle.
  ///
  /// HU38: GET /motorcycles/{id}/profile-image
  Future<Either<ErrorModel, ProfileImageResponse>> getProfileImage(
    String motorcycleId,
  );

  /// Deletes the profile image of a motorcycle.
  ///
  /// HU39: DELETE /motorcycles/{id}/profile-image
  Future<Either<ErrorModel, String>> deleteProfileImage(String motorcycleId);
}

class ProfileImageDataSourceImpl implements ProfileImageDataSource {
  final DioClient _dioClient;

  ProfileImageDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, ProfileImageResponse>> updateProfileImage(
    String motorcycleId,
    String imageUrl,
  ) {
    return _handleProfileImageResponse(
      () => _dioClient.put(
        '/motorcycles/$motorcycleId/profile-image',
        data: {'image_url': imageUrl},
      ),
    );
  }

  @override
  Future<Either<ErrorModel, ProfileImageResponse>> getProfileImage(
    String motorcycleId,
  ) {
    return _handleProfileImageResponse(
      () => _dioClient.get('/motorcycles/$motorcycleId/profile-image'),
    );
  }

  @override
  Future<Either<ErrorModel, String>> deleteProfileImage(
    String motorcycleId,
  ) async {
    try {
      final response = await _dioClient.delete(
        '/motorcycles/$motorcycleId/profile-image',
      );
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }
        final message = responseData['message'] as String? ?? '';
        return Right(message);
      }

      return Left(DioErrorHandler.fromBackendError(responseData));
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  /// Shared handler for update and get profile image responses.
  ///
  /// Both return `ProfileImageResponse` containing the parsed model
  /// and the backend message.
  Future<Either<ErrorModel, ProfileImageResponse>> _handleProfileImageResponse(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final response = await request();
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final message = responseData['message'] as String? ?? '';
        return Right(
          ProfileImageResponse(
            model: ProfileImageModel.fromJson(responseData),
            message: message,
          ),
        );
      }

      return Left(DioErrorHandler.fromBackendError(responseData));
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }
}
