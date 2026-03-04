import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_messages.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';
import 'package:motogo_frontend/src/features/register_franchise/data/models/franchise_model.dart';

/// DataSource for franchise registration operations.
///
/// Uses DioClient with automatic token refresh.
abstract class RegisterFranchiseDataSource {
  /// Registers a new franchise.
  ///
  /// Returns a Record with the created [FranchiseModel] and the backend
  /// success message, or [Left] with [ErrorModel] on failure.
  Future<Either<ErrorModel, (FranchiseModel, String)>> registerFranchise(
    FranchiseModel franchise,
  );
}

class RegisterFranchiseDataSourceImpl implements RegisterFranchiseDataSource {
  final DioClient _dioClient;

  RegisterFranchiseDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, (FranchiseModel, String)>> registerFranchise(
    FranchiseModel franchise,
  ) async {
    try {
      final body = franchise.toJson();

      final response = await _dioClient.post('/franchises', data: body);
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        // Check for success flag
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final message =
            responseData['message'] as String? ??
            FallbackMessages.operationSuccess;

        // Extract data from backend response
        final data = responseData['data'] as Map<String, dynamic>?;
        if (data != null) {
          return Right((FranchiseModel.fromJson(data), message));
        }

        // Return with generated ID if no data in response
        return Right((
          FranchiseModel(
            id: 'generated',
            name: franchise.name,
            description: franchise.description,
            branchIds: franchise.branchIds,
          ),
          message,
        ));
      }
      return Left(
        ErrorModel(
          errorCode: 'PARSE_ERROR',
          message: FallbackMessages.unexpectedError,
        ),
      );
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }
}
