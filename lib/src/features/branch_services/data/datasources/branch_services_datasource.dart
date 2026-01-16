import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';
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

class BranchServicesDataSourceImpl implements BranchServicesDataSource {
  final DioClient _dioClient;

  BranchServicesDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, List<BranchServiceModel>>> getBranchServices(
    String branchId,
  ) async {
    try {
      final response = await _dioClient.get('/branches/$branchId/services');
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final data = responseData['data'] as Map<String, dynamic>?;

        if (data != null) {
          final servicesList = data['services'] as List<dynamic>?;

          if (servicesList != null) {
            final services = servicesList
                .map(
                  (json) =>
                      BranchServiceModel.fromJson(json as Map<String, dynamic>),
                )
                .toList();
            return Right(services);
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

  @override
  Future<Either<ErrorModel, String>> associateService(
    String branchId,
    String serviceId,
  ) async {
    try {
      final response = await _dioClient.post(
        '/branches/$branchId/services',
        data: {
          'service_ids': [serviceId],
        },
      );
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }
        final message =
            responseData['message'] as String? ?? 'Servicio asociado';
        return Right(message);
      }

      return const Right('Servicio asociado');
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  @override
  Future<Either<ErrorModel, String>> dissociateService(
    String branchId,
    String serviceId,
  ) async {
    try {
      final response = await _dioClient.delete(
        '/branches/$branchId/services/$serviceId',
      );
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }
        final message =
            responseData['message'] as String? ?? 'Servicio desasociado';
        return Right(message);
      }

      return const Right('Servicio desasociado');
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }
}
