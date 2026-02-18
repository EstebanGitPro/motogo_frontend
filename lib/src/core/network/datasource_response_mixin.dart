import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_messages.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';

/// Mixin that provides shared response handling for DataSource implementations.
///
/// Eliminates the repeated try/catch + success-check boilerplate across
/// all DataSources that follow the standard backend response format:
/// ```json
/// { "success": true/false, "message": "...", "data": {...} }
/// ```
///
/// Usage:
/// ```dart
/// class MyDataSourceImpl with DataSourceResponseMixin implements MyDataSource {
///   final DioClient _dioClient;
///   // ...
/// }
/// ```
mixin DataSourceResponseMixin {
  /// Handles responses that return a success message string.
  ///
  /// Used for POST, PUT, PATCH, DELETE operations where the backend
  /// returns `{ "success": true, "message": "..." }`.
  Future<Either<ErrorModel, String>> handleMessageResponse(
    Future<Response<dynamic>> Function() request,
    String defaultMessage,
  ) async {
    try {
      final response = await request();
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }
        final message = responseData['message'] as String? ?? defaultMessage;
        return Right(message);
      }

      return Right(defaultMessage);
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  /// Handles responses that return a single data object.
  ///
  /// Used for GET/PUT operations that return
  /// `{ "success": true, "data": { ... } }`.
  Future<Either<ErrorModel, T>> handleDataResponse<T>(
    Future<Response<dynamic>> Function() request,
    T Function(Map<String, dynamic>) fromJson, {
    String errorCode = 'PARSE_ERROR',
  }) async {
    try {
      final response = await request();
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final data = responseData['data'] as Map<String, dynamic>?;
        if (data != null) {
          return Right(fromJson(data));
        }
      }

      return Left(
        ErrorModel(
          errorCode: errorCode,
          message: FallbackMessages.unexpectedError,
        ),
      );
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  /// Handles responses that return a list of items.
  ///
  /// Supports two backend response shapes:
  /// - Flat list: `{ "success": true, "data": [ ... ] }`
  /// - Nested list: `{ "success": true, "data": { "items": [ ... ] } }`
  ///
  /// Use [listKey] to specify the nested key (e.g., `'franchises'`, `'services'`).
  /// If [listKey] is null, expects `data` to be a direct `List`.
  Future<Either<ErrorModel, List<T>>> handleListResponse<T>(
    Future<Response<dynamic>> Function() request,
    T Function(Map<String, dynamic>) fromJson, {
    String? listKey,
  }) async {
    try {
      final response = await request();
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final rawData = responseData['data'];

        List<dynamic>? itemsList;
        if (listKey != null && rawData is Map<String, dynamic>) {
          itemsList = rawData[listKey] as List<dynamic>?;
        } else if (rawData is List<dynamic>) {
          itemsList = rawData;
        }

        if (itemsList != null) {
          final items = itemsList
              .map((item) => fromJson(item as Map<String, dynamic>))
              .toList();
          return Right(items);
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

  /// Handles responses returning a model plus a backend message.
  ///
  /// Used for create/update operations that return
  /// `{ "success": true, "message": "...", "data": { ... } }`.
  ///
  /// If parsing the model from `data` fails (null), returns a Left
  /// with the backend error response.
  Future<Either<ErrorModel, (T, String)>> handleModelWithMessageResponse<T>(
    Future<Response<dynamic>> Function() request,
    T Function(Map<String, dynamic>) fromJson,
    String defaultMessage, {
    String errorCode = 'PARSE_ERROR',
  }) async {
    try {
      final response = await request();
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final message = responseData['message'] as String? ?? defaultMessage;
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          return Right((fromJson(data), message));
        }

        // Some endpoints return model at root level
        return Right((fromJson(responseData), message));
      }

      return Left(
        ErrorModel(
          errorCode: errorCode,
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
