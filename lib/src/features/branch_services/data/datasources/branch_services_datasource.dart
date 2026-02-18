import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/datasource_response_mixin.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/features/branch_services/data/models/branch_service_model.dart';

/// DataSource for fetching branch-specific service data from the API.
///
/// Handles services associated with a specific branch.
abstract class BranchServicesDataSource {
  /// Fetches the list of services associated with a branch.
  Future<Either<ErrorModel, List<BranchServiceModel>>> getBranchServices(
    String branchId,
  );

  /// Associates a service with a branch.
  /// Returns the success message from the backend.
  Future<Either<ErrorModel, String>> associateService(
    String branchId,
    String serviceId,
  );

  /// Dissociates a service from a branch.
  /// Returns the success message from the backend.
  Future<Either<ErrorModel, String>> dissociateService(
    String branchId,
    String serviceId,
  );
}

class BranchServicesDataSourceImpl
    with DataSourceResponseMixin
    implements BranchServicesDataSource {
  final DioClient _dioClient;

  BranchServicesDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, List<BranchServiceModel>>> getBranchServices(
    String branchId,
  ) {
    return handleListResponse(
      () => _dioClient.get('/branches/$branchId/services'),
      (json) => BranchServiceModel.fromJson(json),
      listKey: 'services',
    );
  }

  @override
  Future<Either<ErrorModel, String>> associateService(
    String branchId,
    String serviceId,
  ) {
    return handleMessageResponse(
      () => _dioClient.post(
        '/branches/$branchId/services',
        data: {
          'service_ids': [serviceId],
        },
      ),
      'Servicio asociado',
    );
  }

  @override
  Future<Either<ErrorModel, String>> dissociateService(
    String branchId,
    String serviceId,
  ) {
    return handleMessageResponse(
      () => _dioClient.delete('/branches/$branchId/services/$serviceId'),
      'Servicio desasociado',
    );
  }
}
