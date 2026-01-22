import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/constants/schedule_constants.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';
import 'package:motogo_frontend/src/features/branch_schedules/data/datasources/branch_schedule_datasource.dart';
import 'package:motogo_frontend/src/features/branch_schedules/data/models/day_model.dart';
import 'package:motogo_frontend/src/features/branch_schedules/data/models/schedule_detail_model.dart';
import 'package:motogo_frontend/src/features/branch_schedules/data/models/schedule_model.dart';

/// Implementation of [BranchScheduleDataSource].
///
/// Uses [DioClient] for HTTP requests with automatic token handling.
class BranchScheduleDataSourceImpl implements BranchScheduleDataSource {
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
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final data = responseData['data'] as Map<String, dynamic>?;
        if (data != null) {
          return Right(ScheduleModel.fromJson(data));
        }
        return const Right(null);
      }
      return const Right(null);
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
  Future<Either<ErrorModel, ScheduleModel>> createSchedule(
    String branchId,
  ) async {
    try {
      final response = await _dioClient.post(
        ScheduleConstants.getSchedulesPath(branchId),
      );
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final data = responseData['data'] as Map<String, dynamic>?;
        if (data != null) {
          return Right(ScheduleModel.fromJson(data));
        }

        // Fallback: create with minimal data
        return Right(ScheduleModel(id: '', branchId: branchId, active: true));
      }

      return Left(
        ErrorModel(
          errorCode: ScheduleConstants.parseErrorCode,
          message: ScheduleConstants.parseErrorMessage,
        ),
      );
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  @override
  Future<Either<ErrorModel, ScheduleModel>> updateSchedule(
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

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final data = responseData['data'] as Map<String, dynamic>?;
        if (data != null) {
          return Right(ScheduleModel.fromJson(data));
        }

        // Fallback: return with provided values
        return Right(
          ScheduleModel(
            id: '',
            branchId: branchId,
            active: active ?? true,
            startDate: startDate,
            endDate: endDate,
          ),
        );
      }

      return Left(
        ErrorModel(
          errorCode: ScheduleConstants.parseErrorCode,
          message: ScheduleConstants.parseErrorMessage,
        ),
      );
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
    try {
      final response = await _dioClient.delete(
        ScheduleConstants.getSchedulesPath(branchId),
      );
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }
        final message =
            responseData['message'] as String? ??
            ScheduleConstants.defaultDeleteMessage;
        return Right(message);
      }

      return const Right(ScheduleConstants.defaultDeleteMessage);
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  @override
  Future<Either<ErrorModel, ScheduleModel>> activateSchedule(
    String branchId,
  ) async {
    try {
      final response = await _dioClient.put(
        ScheduleConstants.getActivatePath(branchId),
      );
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final data = responseData['data'] as Map<String, dynamic>?;
        if (data != null) {
          return Right(ScheduleModel.fromJson(data));
        }

        // Fallback: return with active = true
        return Right(ScheduleModel(id: '', branchId: branchId, active: true));
      }

      return Left(
        ErrorModel(
          errorCode: ScheduleConstants.parseErrorCode,
          message: ScheduleConstants.parseErrorMessage,
        ),
      );
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  @override
  Future<Either<ErrorModel, ScheduleModel>> deactivateSchedule(
    String branchId,
  ) async {
    try {
      final response = await _dioClient.put(
        ScheduleConstants.getDeactivatePath(branchId),
      );
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final data = responseData['data'] as Map<String, dynamic>?;
        if (data != null) {
          return Right(ScheduleModel.fromJson(data));
        }

        // Fallback: return with active = false
        return Right(ScheduleModel(id: '', branchId: branchId, active: false));
      }

      return Left(
        ErrorModel(
          errorCode: ScheduleConstants.parseErrorCode,
          message: ScheduleConstants.parseErrorMessage,
        ),
      );
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
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final data = responseData['data'] as Map<String, dynamic>?;
        if (data != null) {
          final daysList = data['days'] as List<dynamic>?;
          if (daysList != null) {
            final days = daysList
                .map((json) => DayModel.fromJson(json as Map<String, dynamic>))
                .toList();
            return Right(days);
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

  // ========== Schedule Details Implementation ==========

  @override
  Future<Either<ErrorModel, List<ScheduleDetailModel>>> getScheduleDetails(
    String branchId,
  ) async {
    try {
      final path = ScheduleConstants.getScheduleDetailsPath(branchId);
      final response = await _dioClient.get(path);
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          // API returns { "data": { "details": [...], "_links": [...] } }
          final detailsList = data['details'];
          if (detailsList is List) {
            final details = detailsList
                .map(
                  (json) => ScheduleDetailModel.fromJson(
                    json as Map<String, dynamic>,
                  ),
                )
                .toList();
            return Right(details);
          }
        }
        return const Right([]);
      }
      return const Right([]);
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
  Future<Either<ErrorModel, ScheduleDetailModel>> createScheduleDetail(
    String branchId, {
    required int dayOfWeek,
    required String openingTime,
    required String closingTime,
    required bool isClosed,
  }) async {
    try {
      final body = <String, dynamic>{
        'day_of_week': dayOfWeek,
        'opening_time': openingTime,
        'closing_time': closingTime,
        'is_closed': isClosed,
      };

      final response = await _dioClient.post(
        ScheduleConstants.getScheduleDetailsPath(branchId),
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
          return Right(ScheduleDetailModel.fromJson(data));
        }
      }

      return Left(
        ErrorModel(
          errorCode: ScheduleConstants.parseErrorCode,
          message: ScheduleConstants.parseErrorMessage,
        ),
      );
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  @override
  Future<Either<ErrorModel, ScheduleDetailModel>> updateScheduleDetail(
    String detailId, {
    required String openingTime,
    required String closingTime,
    required bool isClosed,
  }) async {
    try {
      final body = <String, dynamic>{
        'opening_time': openingTime,
        'closing_time': closingTime,
        'is_closed': isClosed,
      };

      final response = await _dioClient.put(
        '${ScheduleConstants.scheduleDetailEndpoint}/$detailId',
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
          return Right(ScheduleDetailModel.fromJson(data));
        }
      }

      return Left(
        ErrorModel(
          errorCode: ScheduleConstants.parseErrorCode,
          message: ScheduleConstants.parseErrorMessage,
        ),
      );
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  @override
  Future<Either<ErrorModel, String>> deleteScheduleDetail(
    String detailId,
  ) async {
    try {
      final response = await _dioClient.delete(
        '${ScheduleConstants.scheduleDetailEndpoint}/$detailId',
      );
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }
        final message =
            responseData['message'] as String? ??
            ScheduleConstants.defaultDeleteDetailMessage;
        return Right(message);
      }

      return const Right(ScheduleConstants.defaultDeleteDetailMessage);
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }
}
