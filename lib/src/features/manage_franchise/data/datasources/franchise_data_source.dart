import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';
import 'package:motogo_frontend/src/core/errors/error_messages.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';
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

class FranchiseDataSourceImpl implements FranchiseDataSource {
  final DioClient _dioClient;

  FranchiseDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, FranchiseModel>> getFranchise(
    String franchiseId,
  ) async {
    try {
      debugPrint('[Franchise] Getting franchise: $franchiseId');

      final response = await _dioClient.get('/franchises/$franchiseId');
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final data = responseData['data'] as Map<String, dynamic>?;
        if (data != null) {
          return Right(FranchiseModel.fromJson(data));
        }
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

  @override
  Future<Either<ErrorModel, List<FranchiseModel>>> listFranchises() async {
    try {
      debugPrint('[Franchise] Listing franchises');

      final response = await _dioClient.get('/franchises');
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        // Backend returns data.franchises array
        final data = responseData['data'] as Map<String, dynamic>?;
        if (data != null) {
          final franchiseList = data['franchises'] as List<dynamic>?;
          if (franchiseList != null) {
            final franchises = franchiseList
                .map((e) => FranchiseModel.fromJson(e as Map<String, dynamic>))
                .toList();
            debugPrint('[Franchise] Parsed ${franchises.length} franchises');
            return Right(franchises);
          }
        }
        return const Right([]);
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

  @override
  Future<Either<ErrorModel, FranchiseModel>> updateFranchise(
    String franchiseId,
    FranchiseModel franchise,
  ) async {
    try {
      final body = franchise.toJson();
      debugPrint('[Franchise] Updating franchise $franchiseId: $body');

      final response = await _dioClient.put(
        '/franchises/$franchiseId',
        data: body,
      );
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final data = responseData['data'] as Map<String, dynamic>?;
        if (data != null) {
          return Right(FranchiseModel.fromJson(data));
        }
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

  @override
  Future<Either<ErrorModel, String>> deleteFranchise(String franchiseId) async {
    try {
      debugPrint('[Franchise] Deleting franchise: $franchiseId');

      final response = await _dioClient.delete('/franchises/$franchiseId');
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final message =
            responseData['message'] as String? ??
            FallbackMessages.operationSuccess;
        return Right(message);
      }
      return const Right(FallbackMessages.operationSuccess);
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  @override
  Future<Either<ErrorModel, String>> linkBranch(
    String branchId,
    String franchiseId,
  ) async {
    try {
      debugPrint(
        '[Franchise] Linking branch $branchId to franchise $franchiseId',
      );

      // POST /franchises/:id/branches
      final response = await _dioClient.post(
        '/franchises/$franchiseId/branches',
        data: {'branch_id': branchId},
      );
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final message =
            responseData['message'] as String? ??
            FallbackMessages.operationSuccess;
        return Right(message);
      }
      return const Right(FallbackMessages.operationSuccess);
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  @override
  Future<Either<ErrorModel, String>> unlinkBranch(
    String branchId,
    String franchiseId,
  ) async {
    try {
      debugPrint(
        '[Franchise] Unlinking branch $branchId from franchise $franchiseId',
      );

      // DELETE /franchises/:id/branches/:branchId
      final response = await _dioClient.delete(
        '/franchises/$franchiseId/branches/$branchId',
      );
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final message =
            responseData['message'] as String? ??
            FallbackMessages.operationSuccess;
        return Right(message);
      }
      return const Right(FallbackMessages.operationSuccess);
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }
}
