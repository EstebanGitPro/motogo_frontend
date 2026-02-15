import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/service_ratings/domain/entities/rating_range_entity.dart';

/// Repository interface for rating range operations.
abstract class RatingRangeRepository {
  /// Gets the list of available rating ranges.
  Future<Either<ErrorModel, List<RatingRangeEntity>>> getRatingRanges();
}
