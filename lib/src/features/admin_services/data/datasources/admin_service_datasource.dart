import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/constants/service_constants.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/api_response_handler.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';
import 'package:motogo_frontend/src/features/admin_services/data/models/admin_service_model.dart';

/// DataSource for administrative service catalog operations.
///
/// Handles CRUD operations on the global service catalog.
/// Requires ADMIN role.
abstract class AdminServiceDataSource {
  /// Fetches all services from the global catalog.
  Future<Either<ErrorModel, List<AdminServiceModel>>> getServices();

  /// Updates a service in the global catalog (HU68).
  /// Endpoint: PUT /admin/services/{id}
  Future<Either<ErrorModel, AdminServiceModel>> updateService({
    required String serviceId,
    required String name,
    required String serviceType,
    String? description,
    bool? isActive,
  });

  /// Activates a service globally (HU71).
  /// Endpoint: PATCH /admin/services/{id}/activate
  Future<Either<ErrorModel, String>> activateService(String serviceId);

  /// Deactivates a service globally (HU72).
  /// Endpoint: PATCH /admin/services/{id}/deactivate
  Future<Either<ErrorModel, String>> deactivateService(String serviceId);
}

class AdminServiceDataSourceImpl implements AdminServiceDataSource {
  final DioClient _dioClient;

  AdminServiceDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, List<AdminServiceModel>>> getServices() async {
    try {
      final response = await _dioClient.get('/services');
      return ApiResponseHandler.extractList(
        response.data,
        key: 'services',
        fromJson: AdminServiceModel.fromJson,
      );
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  @override
  Future<Either<ErrorModel, AdminServiceModel>> updateService({
    required String serviceId,
    required String name,
    required String serviceType,
    String? description,
    bool? isActive,
  }) async {
    try {
      final requestBody = <String, dynamic>{
        'name': name,
        'service_type': serviceType,
      };
      if (description != null && description.isNotEmpty) {
        requestBody['description'] = description;
      }
      if (isActive != null) {
        requestBody['is_active'] = isActive;
      }

      final response = await _dioClient.put(
        '/admin/services/$serviceId',
        data: requestBody,
      );

      final responseData = response.data;
      final validation = ApiResponseHandler.validate(responseData);
      if (validation.isLeft) return Left(validation.left);

      final data = validation.right;
      if (data != null) {
        return Right(AdminServiceModel.fromJson(data));
      }

      // Fallback: reconstruct from request data
      return Right(
        AdminServiceModel(
          id: serviceId,
          name: name,
          description: description,
          serviceType: serviceType,
          isActive: isActive ?? true,
        ),
      );
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  @override
  Future<Either<ErrorModel, String>> activateService(String serviceId) async {
    try {
      final response = await _dioClient.patch(
        '/admin/services/$serviceId/activate',
      );
      final validation = ApiResponseHandler.validate(response.data);
      if (validation.isLeft) return Left(validation.left);

      return Right(
        ApiResponseHandler.extractMessage(
          response.data,
          ServiceConstants.serviceActivated,
        ),
      );
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  @override
  Future<Either<ErrorModel, String>> deactivateService(String serviceId) async {
    try {
      final response = await _dioClient.patch(
        '/admin/services/$serviceId/deactivate',
      );
      final validation = ApiResponseHandler.validate(response.data);
      if (validation.isLeft) return Left(validation.left);

      return Right(
        ApiResponseHandler.extractMessage(
          response.data,
          ServiceConstants.serviceDeactivated,
        ),
      );
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }
}
