import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/constants/schedule_constants.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/api_response_handler.dart';
import 'package:motogo_frontend/src/core/network/datasource_response_mixin.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';
import 'package:motogo_frontend/src/features/branch_schedules/data/datasources/branch_schedule_datasource.dart';
import 'package:motogo_frontend/src/features/branch_schedules/data/models/day_model.dart';
import 'package:motogo_frontend/src/features/branch_schedules/data/models/schedule_detail_model.dart';
import 'package:motogo_frontend/src/features/branch_schedules/data/models/schedule_exception_model.dart';
import 'package:motogo_frontend/src/features/branch_schedules/data/models/schedule_model.dart';

/// Implementation of [BranchScheduleDataSource].
///
/// Uses [DioClient] for HTTP requests with automatic token handling.
class BranchScheduleDataSourceImpl
    with DataSourceResponseMixin
    implements BranchScheduleDataSource {
  final DioClient _dioClient;

  BranchScheduleDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, ScheduleModel?>> getSchedule(
    String branchId,
  ) async {
    try {
      final response = await _dioClient.get(
        ScheduleConstants.getSchedulesPath(branchId),
      );
      return ApiResponseHandler.extractObject(
        response.data,
        fromJson: ScheduleModel.fromJson,
      );
    } on DioException catch (e) {
      // 404 means no schedule exists - this is a valid state
      if (e.response?.statusCode == 404) {
        return const Right(null);
      }
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  @override
  Future<Either<ErrorModel, (ScheduleModel, String)>> createSchedule(
    String branchId,
  ) async {
    try {
      final response = await _dioClient.post(
        ScheduleConstants.getSchedulesPath(branchId),
      );
      final responseData = response.data;
      final validation = ApiResponseHandler.validate(responseData);
      if (validation.isLeft) return Left(validation.left);

      final message = ApiResponseHandler.extractMessage(
        responseData,
        ScheduleConstants.scheduleCreated,
      );
      final data = validation.right;
      if (data != null) {
        return Right((ScheduleModel.fromJson(data), message));
      }

      // Fallback: create with minimal data
      return Right((
        ScheduleModel(id: '', branchId: branchId, active: true),
        message,
      ));
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  @override
  Future<Either<ErrorModel, (ScheduleModel, String)>> updateSchedule(
    String branchId, {
    bool? active,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Build request body
      final body = <String, dynamic>{};
      if (active != null) body['active'] = active;
      if (startDate != null) body['start_date'] = _formatDate(startDate);
      body['end_date'] = endDate != null ? _formatDate(endDate) : null;

      final response = await _dioClient.put(
        ScheduleConstants.getSchedulesPath(branchId),
        data: body,
      );
      final responseData = response.data;
      final validation = ApiResponseHandler.validate(responseData);
      if (validation.isLeft) return Left(validation.left);

      final message = ApiResponseHandler.extractMessage(
        responseData,
        ScheduleConstants.scheduleUpdated,
      );
      final data = validation.right;
      if (data != null) {
        return Right((ScheduleModel.fromJson(data), message));
      }

      // Fallback: return with provided values
      return Right((
        ScheduleModel(
          id: '',
          branchId: branchId,
          active: active ?? true,
          startDate: startDate,
          endDate: endDate,
        ),
        message,
      ));
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  /// Formats a DateTime to YYYY-MM-DD string for API.
  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<Either<ErrorModel, String>> deleteSchedule(String branchId) async {
    return handleMessageResponse(
      () => _dioClient.delete(ScheduleConstants.getSchedulesPath(branchId)),
      ScheduleConstants.defaultDeleteMessage,
    );
  }

  @override
  Future<Either<ErrorModel, (ScheduleModel, String)>> activateSchedule(
    String branchId,
  ) async {
    return _handleScheduleToggle(
      ScheduleConstants.getActivatePath(branchId),
      branchId,
      true,
      ScheduleConstants.scheduleActivated,
    );
  }

  @override
  Future<Either<ErrorModel, (ScheduleModel, String)>> deactivateSchedule(
    String branchId,
  ) async {
    return _handleScheduleToggle(
      ScheduleConstants.getDeactivatePath(branchId),
      branchId,
      false,
      ScheduleConstants.scheduleDeactivated,
    );
  }

  /// Shared handler for activate/deactivate schedule operations.
  Future<Either<ErrorModel, (ScheduleModel, String)>> _handleScheduleToggle(
    String path,
    String branchId,
    bool activeState,
    String defaultMessage,
  ) async {
    try {
      final response = await _dioClient.put(path);
      final responseData = response.data;
      final validation = ApiResponseHandler.validate(responseData);
      if (validation.isLeft) return Left(validation.left);

      final message = ApiResponseHandler.extractMessage(
        responseData,
        defaultMessage,
      );
      final data = validation.right;
      if (data != null) {
        return Right((ScheduleModel.fromJson(data), message));
      }

      // Fallback: return with active state
      return Right((
        ScheduleModel(id: '', branchId: branchId, active: activeState),
        message,
      ));
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  @override
  Future<Either<ErrorModel, List<DayModel>>> getDaysCatalog() async {
    try {
      final response = await _dioClient.get(
        ScheduleConstants.daysCatalogEndpoint,
      );
      return ApiResponseHandler.extractList(
        response.data,
        key: 'days',
        fromJson: DayModel.fromJson,
      );
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  // ========== Schedule Details Implementation ==========

  @override
  Future<Either<ErrorModel, List<ScheduleDetailModel>>> getScheduleDetails(
    String branchId,
  ) async {
    try {
      final path = ScheduleConstants.getScheduleDetailsPath(branchId);
      final response = await _dioClient.get(path);
      return ApiResponseHandler.extractList(
        response.data,
        key: 'details',
        fromJson: ScheduleDetailModel.fromJson,
      );
    } on DioException catch (e) {
      // 404 means no details exist - return empty list
      if (e.response?.statusCode == 404) {
        return const Right([]);
      }
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  @override
  Future<Either<ErrorModel, (ScheduleDetailModel, String)>>
  createScheduleDetail(
    String branchId, {
    required int dayOfWeek,
    required String openingTime,
    required String closingTime,
    required bool isClosed,
  }) async {
    return handleModelWithMessageResponse(
      () => _dioClient.post(
        ScheduleConstants.getScheduleDetailsPath(branchId),
        data: <String, dynamic>{
          'entry_type': 'REGULAR',
          'day_of_week': dayOfWeek,
          'opening_time': openingTime,
          'closing_time': closingTime,
          'is_closed': isClosed,
        },
      ),
      ScheduleDetailModel.fromJson,
      ScheduleConstants.timeSlotCreated,
    );
  }

  @override
  Future<Either<ErrorModel, String>> updateScheduleDetail(
    String detailId, {
    required String openingTime,
    required String closingTime,
    required bool isClosed,
  }) async {
    return handleMessageResponse(
      () => _dioClient.put(
        '${ScheduleConstants.scheduleDetailEndpoint}/$detailId',
        data: <String, dynamic>{
          'opening_time': openingTime,
          'closing_time': closingTime,
          'is_closed': isClosed,
        },
      ),
      ScheduleConstants.defaultUpdateDetailMessage,
    );
  }

  @override
  Future<Either<ErrorModel, String>> deleteScheduleDetail(
    String detailId,
  ) async {
    return handleMessageResponse(
      () => _dioClient.delete(
        '${ScheduleConstants.scheduleDetailEndpoint}/$detailId',
      ),
      ScheduleConstants.defaultDeleteDetailMessage,
    );
  }

  // ========== Schedule Exceptions Implementation (HU20-25) ==========

  @override
  Future<Either<ErrorModel, List<ScheduleExceptionModel>>>
  getScheduleExceptions(String branchId) async {
    try {
      final path = ScheduleConstants.getScheduleExceptionsPath(branchId);
      final response = await _dioClient.get(path);
      return ApiResponseHandler.extractList(
        response.data,
        key: 'exceptions',
        fromJson: ScheduleExceptionModel.fromJson,
      );
    } on DioException catch (e) {
      // 404 means no exceptions exist - return empty list
      if (e.response?.statusCode == 404) {
        return const Right([]);
      }
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  @override
  Future<Either<ErrorModel, (ScheduleExceptionModel, String)>>
  createScheduleException(
    String branchId, {
    required String exceptionStartDate,
    String? exceptionEndDate,
    required String openingTime,
    required String closingTime,
    required bool isClosed,
  }) async {
    return handleModelWithMessageResponse(
      () => _dioClient.post(
        ScheduleConstants.getScheduleExceptionsPath(branchId),
        data: <String, dynamic>{
          'exception_start_date': exceptionStartDate,
          if (exceptionEndDate != null && exceptionEndDate.isNotEmpty)
            'exception_end_date': exceptionEndDate,
          'opening_time': openingTime,
          'closing_time': closingTime,
          'is_closed': isClosed,
        },
      ),
      ScheduleExceptionModel.fromJson,
      ScheduleConstants.exceptionCreated,
    );
  }

  @override
  Future<Either<ErrorModel, String>> updateScheduleException(
    String exceptionId, {
    required String openingTime,
    required String closingTime,
    required bool isClosed,
  }) async {
    return handleMessageResponse(
      () => _dioClient.put(
        '${ScheduleConstants.scheduleExceptionEndpoint}/$exceptionId',
        data: <String, dynamic>{
          'opening_time': openingTime,
          'closing_time': closingTime,
          'is_closed': isClosed,
        },
      ),
      ScheduleConstants.exceptionUpdated,
    );
  }

  @override
  Future<Either<ErrorModel, String>> deleteScheduleException(
    String exceptionId,
  ) async {
    return handleMessageResponse(
      () => _dioClient.delete(
        '${ScheduleConstants.scheduleExceptionEndpoint}/$exceptionId',
      ),
      ScheduleConstants.defaultDeleteExceptionMessage,
    );
  }

  @override
  Future<Either<ErrorModel, String>> activateScheduleException(
    String exceptionId,
  ) async {
    return handleMessageResponse(
      () => _dioClient.put(
        ScheduleConstants.getExceptionActivatePath(exceptionId),
      ),
      ScheduleConstants.defaultActivateExceptionMessage,
    );
  }

  @override
  Future<Either<ErrorModel, String>> deactivateScheduleException(
    String exceptionId,
  ) async {
    return handleMessageResponse(
      () => _dioClient.put(
        ScheduleConstants.getExceptionDeactivatePath(exceptionId),
      ),
      ScheduleConstants.defaultDeactivateExceptionMessage,
    );
  }
}
