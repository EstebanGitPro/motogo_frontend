import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/data/models/category_line_model.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/data/models/category_model.dart';

/// DataSource for fetching motorcycle categories and their lines from the API.
abstract class CategoryLinesDataSource {
  /// Fetches the list of all motorcycle categories.
  Future<Either<ErrorModel, List<CategoryModel>>> getCategories();

  /// Fetches the list of lines for a specific category.
  Future<Either<ErrorModel, List<CategoryLineModel>>> getCategoryLines(
    String categoryName,
  );
}

class CategoryLinesDataSourceImpl implements CategoryLinesDataSource {
  final DioClient _dioClient;

  CategoryLinesDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, List<CategoryModel>>> getCategories() async {
    try {
      final response = await _dioClient.get('/motorcycle-categories');
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final categories = CategoryModel.fromJsonList(responseData);
        return Right(categories);
      }
      return const Right([]);
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  @override
  Future<Either<ErrorModel, List<CategoryLineModel>>> getCategoryLines(
    String categoryName,
  ) async {
    try {
      final response = await _dioClient.get(
        '/motorcycle-categories/$categoryName/lines',
      );
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final lines = CategoryLineModel.fromJsonList(responseData);
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
