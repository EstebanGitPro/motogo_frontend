import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/data/datasources/brand_lines_datasource.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/entities/brand_line_entity.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/repositories/brand_lines_repository.dart';

/// Implementation of [BrandLinesRepository].
///
/// Fetches brand lines from the data source and maps to domain entities.
class BrandLinesRepositoryImpl implements BrandLinesRepository {
  final BrandLinesDataSource _dataSource;

  BrandLinesRepositoryImpl(this._dataSource);

  @override
  Future<Either<ErrorModel, List<BrandLineEntity>>> getBrandLines(
    String brandId,
  ) async {
    final result = await _dataSource.getBrandLines(brandId);
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }
}
