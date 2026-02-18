import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_messages.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/datasource_response_mixin.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';

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

class DeleteBranchDataSourceImpl
    with DataSourceResponseMixin
    implements DeleteBranchDataSource {
  final DioClient _dioClient;

  DeleteBranchDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, String>> deleteBranch(String id) {
    return handleMessageResponse(
      () => _dioClient.delete('/branches/$id'),
      FallbackMessages.operationSuccess,
    );
  }
}
