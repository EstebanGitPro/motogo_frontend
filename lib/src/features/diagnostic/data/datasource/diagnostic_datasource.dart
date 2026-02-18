import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';
import 'package:motogo_frontend/src/core/network/datasource_response_mixin.dart';
import 'package:motogo_frontend/src/features/diagnostic/data/model/diagnostic_model.dart';

/// Response wrapper that includes both model and backend message.
class DiagnosticResponse {
  final DiagnosticModel model;
  final String message;

  const DiagnosticResponse({required this.model, required this.message});
}

/// DataSource for motorcycle diagnostic operations (HU11-14).
abstract class DiagnosticDataSource {
  /// Creates a diagnostic request for a motorcycle.
  ///
  /// POST /motorcycles/{id}/diagnostics
  Future<Either<ErrorModel, DiagnosticResponse>> createDiagnostic({
    required String motorcycleId,
    required String problemDescription,
    String? branchId,
  });

  /// Lists all diagnostics for a motorcycle.
  ///
  /// GET /motorcycles/{id}/diagnostics
  Future<Either<ErrorModel, List<DiagnosticModel>>> listDiagnostics({
    required String motorcycleId,
  });

  /// Gets a single diagnostic detail.
  ///
  /// GET /motorcycles/{id}/diagnostics/{diagnosticId}
  Future<Either<ErrorModel, DiagnosticModel>> getDiagnostic({
    required String motorcycleId,
    required String diagnosticId,
  });

  /// Updates a diagnostic.
  ///
  /// PUT /motorcycles/{id}/diagnostics/{diagnosticId}
  Future<Either<ErrorModel, String>> updateDiagnostic({
    required String motorcycleId,
    required String diagnosticId,
    required Map<String, dynamic> data,
  });

  /// Deletes a diagnostic.
  ///
  /// DELETE /motorcycles/{id}/diagnostics/{diagnosticId}
  Future<Either<ErrorModel, String>> deleteDiagnostic({
    required String motorcycleId,
    required String diagnosticId,
  });
}

class DiagnosticDataSourceImpl
    with DataSourceResponseMixin
    implements DiagnosticDataSource {
  final DioClient _dioClient;

  DiagnosticDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, DiagnosticResponse>> createDiagnostic({
    required String motorcycleId,
    required String problemDescription,
    String? branchId,
  }) async {
    try {
      final response = await _dioClient.post(
        '/motorcycles/$motorcycleId/diagnostics',
        data: {
          'problem_description': problemDescription,
          if (branchId != null) 'branch_id': branchId,
        },
      );
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final message = responseData['message'] as String? ?? '';
        return Right(
          DiagnosticResponse(
            model: DiagnosticModel.fromJson(responseData),
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
  Future<Either<ErrorModel, List<DiagnosticModel>>> listDiagnostics({
    required String motorcycleId,
  }) async {
    try {
      final response = await _dioClient.get(
        '/motorcycles/$motorcycleId/diagnostics',
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

        final diagnosticList = items
            .whereType<Map<String, dynamic>>()
            .map(DiagnosticModel.fromDataJson)
            .toList();
        return Right(diagnosticList);
      }

      return Left(DioErrorHandler.fromBackendError(responseData));
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  @override
  Future<Either<ErrorModel, DiagnosticModel>> getDiagnostic({
    required String motorcycleId,
    required String diagnosticId,
  }) async {
    return handleDataResponse(
      () => _dioClient.get(
        '/motorcycles/$motorcycleId/diagnostics/$diagnosticId',
      ),
      DiagnosticModel.fromJson,
    );
  }

  @override
  Future<Either<ErrorModel, String>> updateDiagnostic({
    required String motorcycleId,
    required String diagnosticId,
    required Map<String, dynamic> data,
  }) async {
    return handleMessageResponse(
      () => _dioClient.put(
        '/motorcycles/$motorcycleId/diagnostics/$diagnosticId',
        data: data,
      ),
      '',
    );
  }

  @override
  Future<Either<ErrorModel, String>> deleteDiagnostic({
    required String motorcycleId,
    required String diagnosticId,
  }) async {
    return handleMessageResponse(
      () => _dioClient.delete(
        '/motorcycles/$motorcycleId/diagnostics/$diagnosticId',
      ),
      '',
    );
  }
}
