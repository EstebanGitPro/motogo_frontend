/// Mensajes de FALLBACK para errores cuando el backend NO está disponible.
///
/// IMPORTANTE: Estos mensajes solo se usan en situaciones donde no hay
/// respuesta del servidor (errores de red, timeout, etc.).
/// Cuando el backend responde, siempre se usa el mensaje del backend.
///
/// Los mensajes deben ser:
/// - Amigables y empáticos con el usuario
/// - Claros sobre qué pasó
/// - Con sugerencias de qué hacer
class FallbackMessages {
  // ============ ERRORES DE CONEXIÓN ============

  /// Error cuando no hay conexión a internet
  static const String networkError =
      '¡Ups! Parece que no hay conexión a internet. '
      'Revisa tu conexión e intenta de nuevo.';

  /// Error cuando el servidor no responde
  static const String serverError =
      'Lo sentimos, nuestros servidores están ocupados. '
      'Por favor, intenta en unos minutos.';

  /// Error cuando la solicitud tarda demasiado
  static const String timeoutError =
      'La conexión está tardando más de lo esperado. '
      'Revisa tu internet e intenta nuevamente.';

  /// Error genérico cuando algo falla inesperadamente
  static const String genericError =
      'Algo salió mal. Por favor, intenta de nuevo. '
      'Si el problema persiste, contáctanos.';

  /// Error cuando no se puede establecer conexión
  static const String connectionFailed =
      'No pudimos conectar con el servidor. '
      'Verifica tu conexión a internet.';

  /// Error cuando la respuesta del servidor no es válida
  static const String invalidResponse =
      'Recibimos una respuesta inesperada. '
      'Por favor, intenta nuevamente.';
}

/// @deprecated Use FallbackMessages en su lugar
/// Alias para compatibilidad hacia atrás
typedef ValidationMessages = FallbackMessages;
