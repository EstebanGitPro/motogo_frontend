import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/data/models/motorcycle_model.dart';

/// DataSource for fetching the user's motorcycles.
///
/// Uses DioClient with automatic token refresh.
abstract class MyMotorcyclesDataSource {
  /// Fetches all motorcycles for the authenticated user.
  Future<Either<ErrorModel, List<MotorcycleModel>>> getMotorcycles();
}

class MyMotorcyclesDataSourceImpl implements MyMotorcyclesDataSource {
  final DioClient _dioClient;

  MyMotorcyclesDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, List<MotorcycleModel>>> getMotorcycles() async {
    try {
      final response = await _dioClient.get('/motorcycles');
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        // Parse list from 'data' field
        final data = responseData['data'];
        if (data is List) {
          final motorcycles = data
              .whereType<Map<String, dynamic>>()
              .map((json) => MotorcycleModel.fromJson(json))
              .toList();
          return Right(motorcycles);
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
