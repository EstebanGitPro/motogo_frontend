import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/motorcycle_profile_image/data/datasources/profile_image_datasource.dart';
import 'package:motogo_frontend/src/features/motorcycle_profile_image/domain/entities/profile_image_entity.dart';
import 'package:motogo_frontend/src/features/motorcycle_profile_image/domain/repositories/profile_image_repository.dart';

/// Implementation of ProfileImageRepository.
///
/// Bridges the data layer with the domain layer.
class ProfileImageRepositoryImpl implements ProfileImageRepository {
  final ProfileImageDataSource _dataSource;

  ProfileImageRepositoryImpl(this._dataSource);

  @override
  Future<Either<ErrorModel, ProfileImageEntity>> updateProfileImage(
    String motorcycleId,
    String imageUrl,
  ) async {
    final result = await _dataSource.updateProfileImage(motorcycleId, imageUrl);
    return result.map((response) => response.model.toEntity());
  }

  @override
  Future<Either<ErrorModel, ProfileImageEntity>> getProfileImage(
    String motorcycleId,
  ) async {
    final result = await _dataSource.getProfileImage(motorcycleId);
    return result.map((response) => response.model.toEntity());
  }

  @override
  Future<Either<ErrorModel, String>> deleteProfileImage(String motorcycleId) {
    return _dataSource.deleteProfileImage(motorcycleId);
  }
}
