import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/user_home/domain/entities/branch_marker_entity.dart';
import 'package:motogo_frontend/src/features/user_home/domain/repositories/nearby_branches_repository.dart';

/// Use case for getting nearby branches.
class GetNearbyBranchesUseCase {
  final NearbyBranchesRepository _repository;

  GetNearbyBranchesUseCase(this._repository);

  /// Executes the use case to fetch nearby branches.
  Future<Either<ErrorModel, List<BranchMarkerEntity>>> call({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    String? type,
  }) {
    return _repository.getNearbyBranches(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      type: type,
    );
  }
}
