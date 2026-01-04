import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:http/http.dart' as http;
import 'package:motogo_frontend/src/core/errors/error_message_mapper.dart';
import 'package:motogo_frontend/src/core/errors/error_messages.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';

/// Helper centralizado para manejar errores HTTP en los datasources.
///
/// Uso típico:
/// ```dart
/// try {
///   final response = await http.get(...);
///   // procesar response
/// } catch (e) {
///   return HttpErrorHandler.handleException(e);
/// }
/// ```
class HttpErrorHandler {
  /// Maneja excepciones de red y devuelve un ErrorModel apropiado.
  /// Usar en el catch genérico de las llamadas HTTP.
  static Either<ErrorModel, T> handleException<T>(Object exception) {
    if (exception is SocketException) {
      return Left(ErrorModel(message: ValidationMessages.networkError));
    }

    if (exception is TimeoutException) {
      return Left(ErrorModel(message: ValidationMessages.timeoutError));
    }

    if (exception is HttpException) {
      return Left(ErrorModel(message: ValidationMessages.serverError));
    }

    if (exception is http.ClientException) {
      return Left(ErrorModel(message: ValidationMessages.connectionFailed));
    }

    if (exception is FormatException) {
      return Left(ErrorModel(message: 'Respuesta inválida del servidor'));
    }

    // Verificar si es un error de timeout por string
    final errorString = exception.toString();
    if (errorString.contains('timeout')) {
      return Left(ErrorModel(message: ValidationMessages.timeoutError));
    }

    return Left(ErrorModel(message: ValidationMessages.genericError));
  }

  /// Crea un ErrorModel a partir de una respuesta HTTP fallida.
  /// Extrae el mensaje del backend si está disponible.
  static ErrorModel fromHttpResponse(http.Response response) {
    String? serverMessage;
    String? serverCode;

    try {
      final errorData = json.decode(response.body);
      serverMessage = errorData['message']?.toString();
      serverCode = errorData['code']?.toString();
    } catch (_) {
      serverMessage = null;
      serverCode = null;
    }

    final mappedMessage = ErrorMessageMapper.mapHttpError(
      response.statusCode,
      serverMessage,
    );

    return ErrorModel(
      message: mappedMessage,
      errorCode: serverCode ?? response.statusCode.toString(),
      statusCode: response.statusCode,
    );
  }

  /// Extrae mensaje y código de una respuesta exitosa del backend.
  /// Útil para cuando success: false viene en el body.
  static ErrorModel fromBackendError(Map<String, dynamic> responseData) {
    return ErrorModel(
      message:
          responseData['message']?.toString() ??
          ValidationMessages.genericError,
      errorCode: responseData['code']?.toString(),
    );
  }
}
