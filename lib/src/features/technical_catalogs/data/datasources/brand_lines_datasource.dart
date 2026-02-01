import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/data/models/brand_line_model.dart';

/// DataSource for fetching brand lines from the API.
///
/// Implements HU40: Consultar Líneas de Marca.
abstract class BrandLinesDataSource {
  /// Fetches the list of lines for a specific brand.
  Future<Either<ErrorModel, List<BrandLineModel>>> getBrandLines(
    String brandId,
  );
}

class BrandLinesDataSourceImpl implements BrandLinesDataSource {
  final DioClient _dioClient;

  BrandLinesDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, List<BrandLineModel>>> getBrandLines(
    String brandId,
  ) async {
    try {
      final response = await _dioClient.get('/admin/brands/$brandId/lines');
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final lines = BrandLineModel.fromJsonList(responseData);
        return Right(lines);
      }
      return const Right([]);
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }
}
