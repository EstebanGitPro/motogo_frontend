import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';
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

class CompletedServicesDataSourceImpl implements CompletedServicesDataSource {
  final DioClient _dioClient;

  CompletedServicesDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, String>> registerCompletedService(
    RegisterCompletedServiceModel request,
  ) async {
    return _handleMessageResponse(
      () => _dioClient.post('/completed-services', data: request.toJson()),
      'Servicio registrado exitosamente',
    );
  }

  @override
  Future<Either<ErrorModel, List<CompletedServiceModel>>>
  getCompletedServicesByBranch(String branchId) async {
    return _handleListResponse(
      () => _dioClient.get('/branches/$branchId/completed-services'),
      CompletedServiceModel.fromJson,
    );
  }

  @override
  Future<Either<ErrorModel, String>> updateServiceStatus(
    String serviceId,
    String newStatus,
  ) async {
    return _handleMessageResponse(
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
  ) async {
    return _handleListResponse(
      () => _dioClient.get('/completed-services/$serviceId/transitions'),
      StatusTransitionModel.fromJson,
    );
  }

  @override
  Future<Either<ErrorModel, String>> deleteCompletedService(
    String serviceId,
  ) async {
    return _handleMessageResponse(
      () => _dioClient.delete('/completed-services/$serviceId'),
      'Servicio eliminado exitosamente',
    );
  }

  @override
  Future<Either<ErrorModel, List<CompletedServiceModel>>>
  getCompletedServicesByMotorcycle(String motorcycleId) async {
    return _handleListResponse(
      () => _dioClient.get('/motorcycles/$motorcycleId/completed-services'),
      CompletedServiceModel.fromJson,
    );
  }

  /// Handles POST/PATCH responses that return a success message.
  Future<Either<ErrorModel, String>> _handleMessageResponse(
    Future<dynamic> Function() request,
    String defaultMessage,
  ) async {
    try {
      final response = await request();
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }
        final message = responseData['message'] as String? ?? defaultMessage;
        return Right(message);
      }

      return Right(defaultMessage);
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  /// Handles GET responses that return a list of items.
  Future<Either<ErrorModel, List<T>>> _handleListResponse<T>(
    Future<dynamic> Function() request,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await request();
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }
        final dataList = responseData['data'] as List<dynamic>? ?? [];
        final items = dataList
            .map((item) => fromJson(item as Map<String, dynamic>))
            .toList();
        return Right(items);
      }

      return const Right([]);
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }
}
