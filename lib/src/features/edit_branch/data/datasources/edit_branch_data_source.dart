import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';
import 'package:motogo_frontend/src/features/register_branch/data/models/branch_model.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';

/// DataSource for branch editing operations.
///
/// Uses DioClient with automatic token refresh.
abstract class EditBranchDataSource {
  /// Updates an existing branch.
  ///
  /// Returns [Right] with a record containing the updated [BranchEntity]
  /// and the backend success message, or [Left] with [ErrorModel] on failure.
  Future<Either<ErrorModel, (BranchEntity, String)>> updateBranch(
    String id,
    BranchModel branch,
  );
}

class EditBranchDataSourceImpl implements EditBranchDataSource {
  final DioClient _dioClient;

  EditBranchDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, (BranchEntity, String)>> updateBranch(
    String id,
    BranchModel branch,
  ) async {
    try {
      final body = branch.toJson();

      final response = await _dioClient.put('/branches/$id', data: body);
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        // Check for success flag
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final message = responseData['message'] as String? ?? '';

        // Extract updated branch data
        final data = responseData['data'] as Map<String, dynamic>?;
        if (data != null) {
          final updatedBranch = BranchModel.fromJson(data);
          return Right((updatedBranch.toEntity(), message));
        }

        // Fallback: return original branch if no data in response
        return Right((branch.toEntity(), message));
      }
      return Right((branch.toEntity(), ''));
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }
}
