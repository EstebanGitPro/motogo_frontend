import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/user_home/domain/entities/branch_marker_entity.dart';

/// Repository interface for nearby branches operations.
abstract class NearbyBranchesRepository {
  /// Gets branches near the specified location.
  ///
  /// [latitude] and [longitude] specify the center point.
  /// [radiusKm] is the search radius in kilometers.
  /// [type] is an optional filter for branch type (taller, tienda).
  /// [brand] is an optional filter for brand ID.
  /// [displacementRange] is an optional filter for displacement range.
  Future<Either<ErrorModel, List<BranchMarkerEntity>>> getNearbyBranches({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    String? type,
    String? brand,
    String? displacementRange,
  });
}
