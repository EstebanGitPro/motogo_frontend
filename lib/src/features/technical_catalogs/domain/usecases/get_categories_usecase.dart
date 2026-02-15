import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/entities/category_entity.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/repositories/category_lines_repository.dart';

/// Use case for fetching motorcycle categories.
///
/// Retrieves the list of all available motorcycle categories.
class GetCategoriesUseCase {
  final CategoryLinesRepository _repository;

  GetCategoriesUseCase(this._repository);

  /// Fetches all categories.
  Future<Either<ErrorModel, List<CategoryEntity>>> call() {
    return _repository.getCategories();
  }
}
