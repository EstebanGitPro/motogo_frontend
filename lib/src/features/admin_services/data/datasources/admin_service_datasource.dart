import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
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
            // Debug: Log first service to see is_active format
            if (servicesList.isNotEmpty) {
              final first = servicesList.first as Map<String, dynamic>;
              debugPrint('📋 First service: ${first['name']}');
              debugPrint('📋 is_active value: ${first['is_active']}');
              debugPrint(
                '📋 is_active type: ${first['is_active'].runtimeType}',
              );
            }

            final services = servicesList
                .map(
                  (json) =>
                      AdminServiceModel.fromJson(json as Map<String, dynamic>),
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

      // Debug logs
      debugPrint('🔄 ========== ACTUALIZANDO SERVICIO ==========');
      debugPrint('🔄 Service ID: $serviceId');
      debugPrint('🔄 Endpoint: /admin/services/$serviceId');
      debugPrint('🔄 Request Body: $requestBody');
      debugPrint('🔄 =============================================');

      final response = await _dioClient.put(
        '/admin/services/$serviceId',
        data: requestBody,
      );

      debugPrint('✅ Response status: ${response.statusCode}');
      debugPrint('✅ Response data: ${response.data}');

      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final data = responseData['data'] as Map<String, dynamic>?;
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
      }

      return Left(
        ErrorModel(
          errorCode: 'PARSE_ERROR',
          message: 'Error al procesar respuesta del servidor',
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
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }
        final message =
            responseData['message'] as String? ?? 'Servicio activado';
        return Right(message);
      }

      return const Right('Servicio activado');
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
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }
        final message =
            responseData['message'] as String? ?? 'Servicio desactivado';
        return Right(message);
      }

      return const Right('Servicio desactivado');
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }
}
