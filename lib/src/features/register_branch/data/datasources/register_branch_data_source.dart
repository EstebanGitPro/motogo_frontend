import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_messages.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';
import 'package:motogo_frontend/src/features/register_branch/data/models/branch_model.dart';

/// DataSource for branch registration operations.
///
/// Uses DioClient with automatic token refresh.
abstract class RegisterBranchDataSource {
  Future<Either<ErrorModel, String>> registerBranch(BranchModel branch);
}

class RegisterBranchDataSourceImpl implements RegisterBranchDataSource {
  final DioClient _dioClient;

  RegisterBranchDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, String>> registerBranch(BranchModel branch) async {
    try {
      final body = branch.toJson();

      final response = await _dioClient.post('/branches', data: body);
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        // Check for success flag
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        // Extract message from backend (always available in success responses)
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
