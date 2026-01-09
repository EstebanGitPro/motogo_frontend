/// Códigos de error centralizados para la aplicación.
///
/// Estos códigos se usan cuando el backend no proporciona un código
/// específico o para errores que se generan en el cliente.
class ErrorCodes {
  // ============ ERRORES DE SESIÓN ============

  /// Sesión expirada
  static const String sessionExpired = 'SESSION_EXPIRED';

  /// Error al refrescar sesión
  static const String sessionRefreshFailed = 'SESSION_REFRESH_FAILED';

  // ============ ERRORES DE RED ============

  /// Error de red genérico
  static const String networkError = 'NETWORK_ERROR';

  /// Error desconocido
  static const String unknownError = 'UNKNOWN_ERROR';

  /// Respuesta inválida del servidor
  static const String invalidResponse = 'INVALID_RESPONSE';

  /// Respuesta vacía del servidor
  static const String emptyResponse = 'EMPTY_RESPONSE';

  // ============ ERRORES DE FIREBASE ============

  /// Token de Firebase no recibido
  static const String firebaseTokenMissing = 'FIREBASE_TOKEN_MISSING';

  // ============ ERRORES DE AUTENTICACIÓN ============

  /// Token de acceso no recibido
  static const String missingAccessToken = 'MISSING_ACCESS_TOKEN';
}
