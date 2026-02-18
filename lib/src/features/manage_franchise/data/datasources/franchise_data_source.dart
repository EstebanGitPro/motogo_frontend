import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_messages.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/datasource_response_mixin.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/features/register_franchise/data/models/franchise_model.dart';

/// DataSource for franchise management operations (GET, PUT, DELETE).
abstract class FranchiseDataSource {
  /// Gets a franchise by its ID.
  Future<Either<ErrorModel, FranchiseModel>> getFranchise(String franchiseId);

  /// Gets all franchises for the current user.
  Future<Either<ErrorModel, List<FranchiseModel>>> listFranchises();

  /// Updates a franchise.
  Future<Either<ErrorModel, FranchiseModel>> updateFranchise(
    String franchiseId,
    FranchiseModel franchise,
  );

  /// Deletes a franchise.
  Future<Either<ErrorModel, String>> deleteFranchise(String franchiseId);

  /// Links a branch to a franchise.
  /// POST /franchises/:franchiseId/branches with { "branch_id": branchId }
  Future<Either<ErrorModel, String>> linkBranch(
    String branchId,
    String franchiseId,
  );

  /// Unlinks a branch from a franchise.
  /// DELETE /franchises/:franchiseId/branches/:branchId
  Future<Either<ErrorModel, String>> unlinkBranch(
    String branchId,
    String franchiseId,
  );
}

class FranchiseDataSourceImpl
    with DataSourceResponseMixin
    implements FranchiseDataSource {
  final DioClient _dioClient;

  FranchiseDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, FranchiseModel>> getFranchise(String franchiseId) {
    return handleDataResponse(
      () => _dioClient.get('/franchises/$franchiseId'),
      (data) => FranchiseModel.fromJson(data),
    );
  }

  @override
  Future<Either<ErrorModel, List<FranchiseModel>>> listFranchises() {
    return handleListResponse(
      () => _dioClient.get('/franchises'),
      (json) => FranchiseModel.fromJson(json),
      listKey: 'franchises',
    );
  }

  @override
  Future<Either<ErrorModel, FranchiseModel>> updateFranchise(
    String franchiseId,
    FranchiseModel franchise,
  ) {
    return handleDataResponse(
      () =>
          _dioClient.put('/franchises/$franchiseId', data: franchise.toJson()),
      (data) => FranchiseModel.fromJson(data),
    );
  }

  @override
  Future<Either<ErrorModel, String>> deleteFranchise(String franchiseId) {
    return handleMessageResponse(
      () => _dioClient.delete('/franchises/$franchiseId'),
      FallbackMessages.operationSuccess,
    );
  }

  @override
  Future<Either<ErrorModel, String>> linkBranch(
    String branchId,
    String franchiseId,
  ) {
    return handleMessageResponse(
      () => _dioClient.post(
        '/franchises/$franchiseId/branches',
        data: {'branch_id': branchId},
      ),
      FallbackMessages.operationSuccess,
    );
  }

  @override
  Future<Either<ErrorModel, String>> unlinkBranch(
    String branchId,
    String franchiseId,
  ) {
    return handleMessageResponse(
      () => _dioClient.delete('/franchises/$franchiseId/branches/$branchId'),
      FallbackMessages.operationSuccess,
    );
  }
}
