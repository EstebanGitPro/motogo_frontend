import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/entities/category_line_entity.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/repositories/category_lines_repository.dart';

/// Use case for fetching lines of a specific motorcycle category.
///
/// Retrieves the list of motorcycle lines/models for a given category.
class GetCategoryLinesUseCase {
  final CategoryLinesRepository _repository;

  GetCategoryLinesUseCase(this._repository);

  /// Fetches category lines for the given [categoryName].
  Future<Either<ErrorModel, List<CategoryLineEntity>>> call(
    String categoryName,
  ) {
    return _repository.getCategoryLines(categoryName);
  }
}
