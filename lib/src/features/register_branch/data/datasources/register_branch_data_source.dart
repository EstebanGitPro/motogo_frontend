import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_messages.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/datasource_response_mixin.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/features/register_branch/data/models/branch_model.dart';

/// DataSource for branch registration operations.
///
/// Uses DioClient with automatic token refresh.
abstract class RegisterBranchDataSource {
  Future<Either<ErrorModel, String>> registerBranch(BranchModel branch);
}

class RegisterBranchDataSourceImpl
    with DataSourceResponseMixin
    implements RegisterBranchDataSource {
  final DioClient _dioClient;

  RegisterBranchDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, String>> registerBranch(BranchModel branch) {
    return handleMessageResponse(
      () => _dioClient.post('/branches', data: branch.toJson()),
      FallbackMessages.operationSuccess,
    );
  }
}
