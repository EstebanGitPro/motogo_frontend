import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';
import 'package:motogo_frontend/src/core/constants/debug_messages.dart';
import 'package:motogo_frontend/src/core/errors/error_messages.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';

/// DataSource for branch deletion operations.
///
/// Uses DioClient with automatic token refresh.
abstract class DeleteBranchDataSource {
  /// Deletes a branch by its ID.
  ///
  /// Returns [Right] with the success message on success,
  /// or [Left] with [ErrorModel] on failure.
  Future<Either<ErrorModel, String>> deleteBranch(String id);
}

class DeleteBranchDataSourceImpl implements DeleteBranchDataSource {
  final DioClient _dioClient;

  DeleteBranchDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, String>> deleteBranch(String id) async {
    try {
      debugPrint('${DebugMessages.deletingBranch}: $id');

      final response = await _dioClient.delete('/branches/$id');
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        // Check for success flag
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        // Extract message from backend
        final message =
            responseData['message'] as String? ??
            FallbackMessages.operationSuccess;
        return Right(message);
      }
      return const Right(FallbackMessages.operationSuccess);
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }
}
