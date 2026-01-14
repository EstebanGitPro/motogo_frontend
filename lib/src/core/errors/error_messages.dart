/// Mensajes de FALLBACK para cuando el backend NO está disponible.
///
/// IMPORTANTE: Estos mensajes solo se usan cuando no hay respuesta del servidor
/// (errores de red, timeout, etc.) o cuando el backend no incluye un mensaje.
/// Cuando el backend responde con un 'message', siempre se usa ese mensaje.
///
/// Los mensajes deben ser:
/// - Amigables y empáticos con el usuario
/// - Claros sobre qué pasó
/// - Con sugerencias de qué hacer

// ============ ERRORES DE CONEXIÓN ============

class FallbackMessages {
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

  // ============ ERRORES HTTP ESPECÍFICOS ============

  /// Error 404 - Recurso no encontrado
  static const String notFound =
      'Lo que buscas no está disponible en este momento. '
      'Si el problema persiste, contáctanos.';

  /// Error 401 - No autorizado
  static const String unauthorized =
      'Tu sesión ha expirado. '
      'Por favor, inicia sesión nuevamente.';

  /// Error 403 - Prohibido
  static const String forbidden =
      'No tienes permisos para realizar esta acción. '
      'Si crees que esto es un error, contáctanos.';

  /// Error 400 - Solicitud incorrecta
  static const String badRequest =
      'Hubo un problema con la información enviada. '
      'Por favor, verifica los datos e intenta de nuevo.';

  /// Error 409 - Conflicto
  static const String conflict =
      'Esta información ya existe en el sistema. '
      'Por favor, verifica los datos.';

  /// Error 422 - Validación fallida
  static const String validationError =
      'Algunos datos no son válidos. '
      'Por favor, revisa la información e intenta de nuevo.';

  /// Error 429 - Demasiadas solicitudes
  static const String tooManyRequests =
      'Has realizado demasiadas solicitudes. '
      'Por favor, espera un momento e intenta de nuevo.';

  // ============ ERRORES DE SESIÓN ============

  /// Error al refrescar sesión
  static const String sessionRefreshError = 'Error al refrescar sesión';

  /// Sesión expirada - requiere login
  static const String sessionExpired =
      'Sesión expirada. Por favor, inicia sesión nuevamente.';

  // ============ ERRORES TÉCNICOS ============

  /// Error de certificado SSL
  static const String sslCertificateError = 'Error de certificado SSL';

  /// Solicitud cancelada
  static const String requestCancelled = 'Solicitud cancelada';

  /// Error de conexión genérico
  static const String connectionError = 'Error de conexión';

  /// Error inesperado
  static const String unexpectedError = 'Error inesperado';

  // ============ MENSAJES DE ÉXITO (FALLBACK) ============

  /// Mensaje genérico de éxito cuando el backend no envía uno
  static const String operationSuccess = 'Operación exitosa';

  /// Respuesta del servidor incompleta
  static const String incompleteServerResponse =
      'Respuesta del servidor incompleta';

  /// Error genérico de registro
  static const String registerError = 'Error en el registro';
}

/// @deprecated Use FallbackMessages en su lugar
/// Alias para compatibilidad hacia atrás
typedef ValidationMessages = FallbackMessages;
