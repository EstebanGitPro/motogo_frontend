import 'package:motogo_frontend/src/core/errors/error_messages.dart';

/// Mapper de errores simplificado.
///
/// FILOSOFÍA:
/// - Si el backend responde con un mensaje, USARLO DIRECTAMENTE
/// - Solo usar fallbacks cuando hay problemas de red (sin respuesta del backend)
class ErrorMessageMapper {
  /// Mapea un mensaje del servidor.
  /// Si el mensaje está vacío, retorna un fallback apropiado.
  static String mapServerError(String serverMessage) {
    if (serverMessage.isEmpty) {
      return FallbackMessages.genericError;
    }

    final lowerMessage = serverMessage.toLowerCase();

    // Solo mapear códigos internos de red, no mensajes del backend
    switch (lowerMessage) {
      case 'network_error':
      case 'connection_error':
        return FallbackMessages.networkError;
      case 'server_error':
      case 'internal_server_error':
        return FallbackMessages.serverError;
      case 'timeout':
      case 'request_timeout':
        return FallbackMessages.timeoutError;
      default:
        // USAR EL MENSAJE DEL BACKEND DIRECTAMENTE
        return serverMessage;
    }
  }

  /// Mapea errores HTTP cuando NO hay mensaje del backend.
  /// Si hay mensaje del servidor, usarlo directamente.
  static String mapHttpError(int statusCode, [String? serverMessage]) {
    // Si hay mensaje del backend, usarlo
    if (serverMessage != null && serverMessage.isNotEmpty) {
      return mapServerError(serverMessage);
    }

    // Sin mensaje del backend, usar fallbacks según código HTTP
    switch (statusCode) {
      case 0: // Sin conexión
        return FallbackMessages.networkError;
      case 400: // Bad Request
        return FallbackMessages.badRequest;
      case 401: // Unauthorized
        return FallbackMessages.unauthorized;
      case 403: // Forbidden
        return FallbackMessages.forbidden;
      case 404: // Not Found
        return FallbackMessages.notFound;
      case 408: // Timeout
        return FallbackMessages.timeoutError;
      case 409: // Conflict
        return FallbackMessages.conflict;
      case 422: // Unprocessable Entity
        return FallbackMessages.validationError;
      case 429: // Too Many Requests
        return FallbackMessages.tooManyRequests;
      case 500:
      case 502:
      case 503:
      case 504:
        return FallbackMessages.serverError;
      default:
        return FallbackMessages.genericError;
    }
  }
}
