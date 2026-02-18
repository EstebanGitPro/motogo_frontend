import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/datasource_response_mixin.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/features/completed_services/data/model/completed_service_model.dart';
import 'package:motogo_frontend/src/features/completed_services/data/model/register_completed_service_model.dart';
import 'package:motogo_frontend/src/features/completed_services/data/model/status_transition_model.dart';

/// DataSource for registering completed services.
///
/// Uses DioClient with automatic token refresh.
abstract class CompletedServicesDataSource {
  /// Registers a completed service for a motorcycle at a branch.
  ///
  /// Calls POST /completed-services with the given request body.
  /// Returns the success message from the backend.
  Future<Either<ErrorModel, String>> registerCompletedService(
    RegisterCompletedServiceModel request,
  );

  /// Fetches completed services for a specific branch.
  ///
  /// Calls GET /branches/{branchId}/completed-services.
  Future<Either<ErrorModel, List<CompletedServiceModel>>>
  getCompletedServicesByBranch(String branchId);

  /// Fetches completed services for a specific motorcycle.
  ///
  /// Calls GET /motorcycles/{motorcycleId}/completed-services.
  Future<Either<ErrorModel, List<CompletedServiceModel>>>
  getCompletedServicesByMotorcycle(String motorcycleId);

  /// Updates the status of a completed service.
  ///
  /// Calls PATCH /completed-services/{serviceId}/status.
  /// Returns the success message from the backend.
  Future<Either<ErrorModel, String>> updateServiceStatus(
    String serviceId,
    String newStatus,
  );

  /// Fetches status transitions for a completed service.
  ///
  /// Calls GET /completed-services/{serviceId}/transitions.
  Future<Either<ErrorModel, List<StatusTransitionModel>>> getServiceTransitions(
    String serviceId,
  );

  /// Deletes a completed service.
  ///
  /// Calls DELETE /completed-services/{serviceId}.
  /// Returns the success message from the backend.
  Future<Either<ErrorModel, String>> deleteCompletedService(String serviceId);
}

class CompletedServicesDataSourceImpl
    with DataSourceResponseMixin
    implements CompletedServicesDataSource {
  final DioClient _dioClient;

  CompletedServicesDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, String>> registerCompletedService(
    RegisterCompletedServiceModel request,
  ) {
    return handleMessageResponse(
      () => _dioClient.post('/completed-services', data: request.toJson()),
      'Servicio registrado exitosamente',
    );
  }

  @override
  Future<Either<ErrorModel, List<CompletedServiceModel>>>
  getCompletedServicesByBranch(String branchId) {
    return handleListResponse(
      () => _dioClient.get('/branches/$branchId/completed-services'),
      CompletedServiceModel.fromJson,
    );
  }

  @override
  Future<Either<ErrorModel, List<CompletedServiceModel>>>
  getCompletedServicesByMotorcycle(String motorcycleId) {
    return handleListResponse(
      () => _dioClient.get('/motorcycles/$motorcycleId/completed-services'),
      CompletedServiceModel.fromJson,
    );
  }

  @override
  Future<Either<ErrorModel, String>> updateServiceStatus(
    String serviceId,
    String newStatus,
  ) {
    return handleMessageResponse(
      () => _dioClient.patch(
        '/completed-services/$serviceId/status',
        data: {'status': newStatus},
      ),
      'Estado actualizado exitosamente',
    );
  }

  @override
  Future<Either<ErrorModel, List<StatusTransitionModel>>> getServiceTransitions(
    String serviceId,
  ) {
    return handleListResponse(
      () => _dioClient.get('/completed-services/$serviceId/transitions'),
      StatusTransitionModel.fromJson,
    );
  }

  @override
  Future<Either<ErrorModel, String>> deleteCompletedService(String serviceId) {
    return handleMessageResponse(
      () => _dioClient.delete('/completed-services/$serviceId'),
      'Servicio eliminado exitosamente',
    );
  }
}
