import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';
import 'package:motogo_frontend/src/features/motorcycle_references/data/models/motorcycle_reference_model.dart';

/// DataSource for fetching motorcycle references catalog.
abstract class MotorcycleReferenceDataSource {
  /// Gets all motorcycle references from the catalog.
  /// Endpoint: GET /motorcycle-references
  Future<Either<ErrorModel, List<MotorcycleReferenceModel>>> getReferences();
}

class MotorcycleReferenceDataSourceImpl
    implements MotorcycleReferenceDataSource {
  final DioClient _dioClient;

  MotorcycleReferenceDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, List<MotorcycleReferenceModel>>>
  getReferences() async {
    try {
      final response = await _dioClient.get('/motorcycle-references');
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        // Parse references from data.references
        final data = responseData['data'] as Map<String, dynamic>?;
        if (data != null) {
          final referencesList = data['references'] as List?;
          if (referencesList != null) {
            final references = referencesList
                .whereType<Map<String, dynamic>>()
                .map((json) => MotorcycleReferenceModel.fromJson(json))
                .toList();
            return Right(references);
          }
        }
        return const Right([]);
      }

      return const Right([]);
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }
}
