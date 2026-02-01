import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/entities/brand_line_entity.dart';

/// Repository interface for brand lines operations.
///
/// Defines the contract for HU40: Consultar Líneas de Marca.
abstract class BrandLinesRepository {
  /// Fetches the list of lines for a specific brand.
  Future<Either<ErrorModel, List<BrandLineEntity>>> getBrandLines(
    String brandId,
  );
}
