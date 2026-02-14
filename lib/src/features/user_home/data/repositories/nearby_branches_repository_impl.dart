import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/user_home/data/datasources/nearby_branches_datasource.dart';
import 'package:motogo_frontend/src/features/user_home/domain/entities/branch_marker_entity.dart';
import 'package:motogo_frontend/src/features/user_home/domain/repositories/nearby_branches_repository.dart';

/// Implementation of NearbyBranchesRepository.
class NearbyBranchesRepositoryImpl implements NearbyBranchesRepository {
  final NearbyBranchesDataSource _dataSource;

  NearbyBranchesRepositoryImpl(this._dataSource);

  @override
  Future<Either<ErrorModel, List<BranchMarkerEntity>>> getNearbyBranches({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    String? type,
    String? brand,
    String? displacementRange,
  }) async {
    final result = await _dataSource.getNearbyBranches(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      type: type,
      brand: brand,
      displacementRange: displacementRange,
    );

    return result.fold(
      (error) => Left(error),
      (models) => Right(models.map((m) => m.toEntity()).toList()),
    );
  }
}
