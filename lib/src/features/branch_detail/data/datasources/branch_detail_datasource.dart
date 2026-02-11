import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/constants/branch_detail_constants.dart';
import 'package:motogo_frontend/src/core/errors/error_messages.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';
import 'package:motogo_frontend/src/features/branch_detail/data/models/branch_detail_model.dart';

/// DataSource for fetching branch/branch detail from the API.
///
/// Handles the GET /branches/{id} endpoint.
abstract class BranchDetailDataSource {
  /// Fetches the branch detail by ID.
  Future<Either<ErrorModel, BranchDetailModel>> getBranchDetail(
    String branchId,
  );
}

/// Implementation of [BranchDetailDataSource] using DioClient.
class BranchDetailDataSourceImpl implements BranchDetailDataSource {
  final DioClient _dioClient;

  BranchDetailDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, BranchDetailModel>> getBranchDetail(
    String branchId,
  ) async {
    try {
      final response = await _dioClient.get('/branches/$branchId');
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final data = responseData['data'] as Map<String, dynamic>?;
        if (data != null) {
          return Right(BranchDetailModel.fromJson(data));
        }

        return Left(
          ErrorModel(
            message: BranchDetailConstants.workshopNotFound,
            errorCode: 'WORKSHOP_NOT_FOUND',
          ),
        );
      }

      return Left(
        ErrorModel(
          message: FallbackMessages.invalidResponse,
          errorCode: 'INVALID_RESPONSE',
        ),
      );
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }
}
