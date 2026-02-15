import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/service_ratings/data/datasources/rating_range_datasource.dart';
import 'package:motogo_frontend/src/features/service_ratings/domain/entities/rating_range_entity.dart';
import 'package:motogo_frontend/src/features/service_ratings/domain/repositories/rating_range_repository.dart';

/// Implementation of [RatingRangeRepository].
///
/// Delegates to [RatingRangeDataSource] and maps models to entities.
class RatingRangeRepositoryImpl implements RatingRangeRepository {
  final RatingRangeDataSource _dataSource;

  RatingRangeRepositoryImpl(this._dataSource);

  @override
  Future<Either<ErrorModel, List<RatingRangeEntity>>> getRatingRanges() async {
    final result = await _dataSource.getRatingRanges();
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }
}
