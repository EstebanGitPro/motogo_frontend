

import 'package:motogo_frontend/src/core/errors/error_messages.dart';

class ErrorMessageMapper {
  /// Mapea errores del servidor/backend a mensajes localizados
  static String mapServerError(String serverMessage) {
    final lowerMessage = serverMessage.toLowerCase();
    
    // Mapeo específico basado en los errores de tu backend Go
    if (lowerMessage.contains('email not verified') || 
        lowerMessage.contains('correo no verificado')) {
      return ValidationMessages.emailNotVerified;
    }
    if (lowerMessage.contains('invalid credentials') || 
        lowerMessage.contains('credenciales inválidas')) {
      return ValidationMessages.invalidCredentials;
    }
    if (lowerMessage.contains('invalid json') || 
        lowerMessage.contains('formato json inválido')) {
      return ValidationMessages.invalidJsonFormat;
    }
    if (lowerMessage.contains('validation') || 
        lowerMessage.contains('validación')) {
      return ValidationMessages.validationError;
    }
    
    switch (lowerMessage) {
      case 'network_error':
      case 'connection_error':
        return ValidationMessages.networkError;
      case 'server_error':
      case 'internal_server_error':
        return ValidationMessages.serverError;
      case 'timeout':
      case 'request_timeout':
        return ValidationMessages.timeoutError;
      default:
        return serverMessage.isNotEmpty ? serverMessage : ValidationMessages.genericError;
    }
  }

  static String mapHttpError(int statusCode, [String? serverMessage]) {
    switch (statusCode) {
      case 400:
        return serverMessage != null 
            ? mapServerError(serverMessage) 
            : ValidationMessages.invalidJsonFormat;
      case 401:
        return ValidationMessages.invalidCredentials;
      case 403:
        return ValidationMessages.emailNotVerified;
      case 422:
        return serverMessage != null 
            ? mapServerError(serverMessage) 
            : ValidationMessages.validationError;
      case 500:
      case 503:
        return ValidationMessages.serverError;
      case 408:
        return ValidationMessages.timeoutError;
      default:
        return serverMessage != null 
            ? mapServerError(serverMessage) 
            : ValidationMessages.genericError;
    }
  }
}
