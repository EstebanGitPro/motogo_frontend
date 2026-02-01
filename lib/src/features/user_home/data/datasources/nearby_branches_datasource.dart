import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';
import 'package:motogo_frontend/src/features/user_home/data/models/branch_marker_model.dart';

/// DataSource for fetching nearby branches from the API.
abstract class NearbyBranchesDataSource {
  /// Fetches branches near the specified location.
  Future<Either<ErrorModel, List<BranchMarkerModel>>> getNearbyBranches({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    String? type,
  });
}

class NearbyBranchesDataSourceImpl implements NearbyBranchesDataSource {
  final DioClient _dioClient;

  NearbyBranchesDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, List<BranchMarkerModel>>> getNearbyBranches({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    String? type,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'lat': latitude,
        'lng': longitude,
        'radius': radiusKm,
      };

      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }

      final response = await _dioClient.get(
        '/branches/nearby',
        queryParameters: queryParams,
      );

      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          final branchesJson = data['branches'] as List<dynamic>? ?? [];
          final branches = branchesJson
              .map(
                (json) =>
                    BranchMarkerModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();
          return Right(branches);
        }
      }

      return const Right([]);
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }
}
