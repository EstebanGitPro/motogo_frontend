import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/data/datasources/category_lines_datasource.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/entities/category_entity.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/entities/category_line_entity.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/repositories/category_lines_repository.dart';

/// Implementation of [CategoryLinesRepository].
///
/// Fetches data from the data source and maps models to domain entities.
class CategoryLinesRepositoryImpl implements CategoryLinesRepository {
  final CategoryLinesDataSource _dataSource;

  CategoryLinesRepositoryImpl(this._dataSource);

  @override
  Future<Either<ErrorModel, List<CategoryEntity>>> getCategories() async {
    final result = await _dataSource.getCategories();
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<ErrorModel, List<CategoryLineEntity>>> getCategoryLines(
    String categoryName,
  ) async {
    final result = await _dataSource.getCategoryLines(categoryName);
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }
}
