import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';

/// Centralized handler for standard API response validation and extraction.
///
/// Encapsulates the repeated pattern of:
/// 1. Checking that `responseData` is a `Map<String, dynamic>`
/// 2. Checking `success != false`
/// 3. Extracting the `data` sub-map or `message` field
///
/// Usage:
/// ```dart
/// final responseData = response.data;
/// final validation = ApiResponseHandler.validate(responseData);
/// if (validation.isLeft) return Left(validation.left);
/// final data = validation.right;  // nullable Map<String, dynamic>
/// ```
class ApiResponseHandler {
  /// Validates a standard API response.
  ///
  /// Returns `Right(data)` where `data` is `responseData['data']` (may be
  /// null if the response has no data field).
  /// Returns `Left(ErrorModel)` if `success == false`.
  /// Returns `Right(null)` if `responseData` is not a Map.
  static Either<ErrorModel, Map<String, dynamic>?> validate(
    dynamic responseData,
  ) {
    if (responseData is! Map<String, dynamic>) {
      return const Right(null);
    }

    final success = responseData['success'] as bool?;
    if (success == false) {
      return Left(DioErrorHandler.fromBackendError(responseData));
    }

    final rawData = responseData['data'];
    final data = rawData is Map<String, dynamic> ? rawData : null;
    return Right(data);
  }

  /// Extracts the `message` field from a standard API response.
  ///
  /// Returns the message if present, otherwise returns [fallback].
  static String extractMessage(dynamic responseData, String fallback) {
    if (responseData is Map<String, dynamic>) {
      return responseData['message'] as String? ?? fallback;
    }
    return fallback;
  }

  /// Validates the response and extracts a list from `data[key]`.
  ///
  /// Each item is mapped using [fromJson]. Returns an empty list if the key
  /// is missing or null.
  static Either<ErrorModel, List<T>> extractList<T>(
    dynamic responseData, {
    required String key,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    final validation = validate(responseData);
    if (validation.isLeft) return Left(validation.left);

    final data = validation.right;
    if (data == null) return const Right([]);

    final list = data[key] as List<dynamic>?;
    if (list == null) return const Right([]);

    final items = list
        .map((json) => fromJson(json as Map<String, dynamic>))
        .toList();
    return Right(items);
  }

  /// Validates the response and extracts a single object from `data`.
  ///
  /// Maps the `data` map using [fromJson]. Returns null if data is missing.
  static Either<ErrorModel, T?> extractObject<T>(
    dynamic responseData, {
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    final validation = validate(responseData);
    if (validation.isLeft) return Left(validation.left);

    final data = validation.right;
    if (data == null) return const Right(null);

    return Right(fromJson(data));
  }
}
