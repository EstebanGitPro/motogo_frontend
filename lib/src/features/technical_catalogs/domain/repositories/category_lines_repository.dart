import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/entities/category_entity.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/entities/category_line_entity.dart';

/// Repository interface for motorcycle category operations.
///
/// Defines the contract for consulting categories and their lines.
abstract class CategoryLinesRepository {
  /// Fetches the list of all motorcycle categories.
  Future<Either<ErrorModel, List<CategoryEntity>>> getCategories();

  /// Fetches the list of lines for a specific category.
  Future<Either<ErrorModel, List<CategoryLineEntity>>> getCategoryLines(
    String categoryName,
  );
}
