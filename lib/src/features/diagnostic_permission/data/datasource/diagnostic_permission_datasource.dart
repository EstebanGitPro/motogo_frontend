import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';
import 'package:motogo_frontend/src/features/diagnostic_permission/data/model/diagnostic_permission_model.dart';

/// Response wrapper for permission grant operations.
class PermissionGrantResponse {
  final DiagnosticPermissionModel model;
  final String message;

  const PermissionGrantResponse({required this.model, required this.message});
}

/// DataSource for diagnostic permission operations.
abstract class DiagnosticPermissionDataSource {
  /// Grants a branch permission to access a motorcycle's diagnostic data.
  ///
  /// POST /motorcycles/{id}/permissions
  Future<Either<ErrorModel, PermissionGrantResponse>> grantPermission({
    required String motorcycleId,
    required String branchId,
  });

  /// Lists all granted permissions for a motorcycle.
  ///
  /// GET /motorcycles/{id}/permissions
  Future<Either<ErrorModel, List<DiagnosticPermissionModel>>> listPermissions({
    required String motorcycleId,
  });

  /// Revokes a branch's permission to access a motorcycle.
  ///
  /// DELETE /motorcycles/{id}/permissions/{branchId}
  Future<Either<ErrorModel, String>> revokePermission({
    required String motorcycleId,
    required String branchId,
  });
}

class DiagnosticPermissionDataSourceImpl
    implements DiagnosticPermissionDataSource {
  final DioClient _dioClient;

  DiagnosticPermissionDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, PermissionGrantResponse>> grantPermission({
    required String motorcycleId,
    required String branchId,
  }) async {
    try {
      final response = await _dioClient.post(
        '/motorcycles/$motorcycleId/permissions',
        data: {'branch_id': branchId},
      );
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final message = responseData['message'] as String? ?? '';
        return Right(
          PermissionGrantResponse(
            model: DiagnosticPermissionModel.fromJson(responseData),
            message: message,
          ),
        );
      }

      return Left(DioErrorHandler.fromBackendError(responseData));
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  @override
  Future<Either<ErrorModel, List<DiagnosticPermissionModel>>> listPermissions({
    required String motorcycleId,
  }) async {
    try {
      final response = await _dioClient.get(
        '/motorcycles/$motorcycleId/permissions',
      );
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final data = responseData['data'];
        List<dynamic>? items;
        if (data is List) {
          items = data;
        } else if (data is Map<String, dynamic>) {
          final nestedItems = data['items'];
          if (nestedItems is List) {
            items = nestedItems;
          }
        }

        if (items == null) {
          return const Right([]);
        }

        final permissionList = items
            .whereType<Map<String, dynamic>>()
            .map(DiagnosticPermissionModel.fromDataJson)
            .toList();
        return Right(permissionList);
      }

      return Left(DioErrorHandler.fromBackendError(responseData));
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  @override
  Future<Either<ErrorModel, String>> revokePermission({
    required String motorcycleId,
    required String branchId,
  }) async {
    try {
      final response = await _dioClient.delete(
        '/motorcycles/$motorcycleId/permissions/$branchId',
      );
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final message = responseData['message'] as String? ?? '';
        return Right(message);
      }

      return Left(DioErrorHandler.fromBackendError(responseData));
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }
}
