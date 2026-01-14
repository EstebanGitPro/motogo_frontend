import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';
import 'package:motogo_frontend/src/features/register_branch/data/models/branch_model.dart';

/// DataSource for fetching the user's branches.
///
/// Uses DioClient with automatic token refresh.
abstract class MyBranchesDataSource {
  /// Fetches all branches for the authenticated user.
  Future<Either<ErrorModel, List<BranchModel>>> getBranches();
}

class MyBranchesDataSourceImpl implements MyBranchesDataSource {
  final DioClient _dioClient;

  MyBranchesDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, List<BranchModel>>> getBranches() async {
    try {
      final response = await _dioClient.get('/branches');
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        // Check for success flag
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        // Parse the data object with branches array
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          final branchesData = data['branches'];
          if (branchesData is List) {
            final branches = branchesData
                .map(
                  (item) => BranchModel.fromJson(item as Map<String, dynamic>),
                )
                .toList();
            return Right(branches);
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
