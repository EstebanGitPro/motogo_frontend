import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_message_mapper.dart';
import 'package:motogo_frontend/src/core/errors/error_messages.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';

/// Helper centralizado para manejar errores de Dio en los datasources.
///
/// Uso típico:
/// ```dart
/// try {
///   final response = await dioClient.get('/branches');
///   // procesar response
/// } on DioException catch (e) {
///   return DioErrorHandler.handleDioException(e);
/// } catch (e) {
///   return DioErrorHandler.handleException(e);
/// }
/// ```
class DioErrorHandler {
  /// Maneja excepciones de Dio y devuelve un ErrorModel apropiado.
  static Either<ErrorModel, T> handleDioException<T>(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Left(ErrorModel(message: FallbackMessages.timeoutError));

      case DioExceptionType.connectionError:
        return Left(ErrorModel(message: FallbackMessages.networkError));

      case DioExceptionType.badResponse:
        return Left(_fromDioResponse(exception.response));

      case DioExceptionType.cancel:
        return Left(ErrorModel(message: FallbackMessages.requestCancelled));

      case DioExceptionType.badCertificate:
        return Left(ErrorModel(message: FallbackMessages.sslCertificateError));

      case DioExceptionType.unknown:
        if (exception.error is SocketException) {
          return Left(ErrorModel(message: FallbackMessages.networkError));
        }
        return Left(ErrorModel(message: FallbackMessages.genericError));
    }
  }

  /// Maneja excepciones genéricas (no-Dio).
  static Either<ErrorModel, T> handleException<T>(Object exception) {
    if (exception is DioException) {
      return handleDioException(exception);
    }

    if (exception is SocketException) {
      return Left(ErrorModel(message: FallbackMessages.networkError));
    }

    if (exception is TimeoutException) {
      return Left(ErrorModel(message: FallbackMessages.timeoutError));
    }

    if (exception is FormatException) {
      return Left(ErrorModel(message: FallbackMessages.invalidResponse));
    }

    final errorString = exception.toString();
    if (errorString.contains('timeout')) {
      return Left(ErrorModel(message: FallbackMessages.timeoutError));
    }

    return Left(ErrorModel(message: FallbackMessages.genericError));
  }

  /// Crea un ErrorModel a partir de una respuesta de Dio.
  static ErrorModel _fromDioResponse(Response<dynamic>? response) {
    if (response == null) {
      return ErrorModel(message: FallbackMessages.serverError);
    }

    String? serverMessage;
    String? serverCode;

    try {
      final errorData = response.data;
      if (errorData is Map<String, dynamic>) {
        serverMessage = errorData['message']?.toString();
        serverCode = errorData['code']?.toString();
      }
    } catch (_) {
      serverMessage = null;
      serverCode = null;
    }

    final mappedMessage = ErrorMessageMapper.mapHttpError(
      response.statusCode ?? 500,
      serverMessage,
    );

    return ErrorModel(
      message: mappedMessage,
      errorCode: serverCode ?? response.statusCode.toString(),
      statusCode: response.statusCode,
    );
  }

  /// Extrae mensaje y código de una respuesta del backend.
  /// Útil para cuando success: false viene en el body.
  static ErrorModel fromBackendError(Map<String, dynamic> responseData) {
    return ErrorModel(
      message:
          responseData['message']?.toString() ?? FallbackMessages.genericError,
      errorCode: responseData['code']?.toString(),
    );
  }
}
