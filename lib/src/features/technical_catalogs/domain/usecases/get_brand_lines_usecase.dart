import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/entities/brand_line_entity.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/repositories/brand_lines_repository.dart';

/// Use case for fetching brand lines (HU40).
///
/// Retrieves the list of motorcycle lines/models for a specific brand.
class GetBrandLinesUseCase {
  final BrandLinesRepository _repository;

  GetBrandLinesUseCase(this._repository);

  /// Fetches brand lines for the given [brandId].
  Future<Either<ErrorModel, List<BrandLineEntity>>> call(String brandId) {
    return _repository.getBrandLines(brandId);
  }
}
