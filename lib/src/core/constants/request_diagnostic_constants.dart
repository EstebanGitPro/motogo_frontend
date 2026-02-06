/// Constants for the request diagnostic feature.
///
/// Use these constants instead of hardcoded strings for better maintainability.
class RequestDiagnosticConstants {
  // Page title
  static const String pageTitle = 'Diagnóstico para';

  // Section titles
  static const String sectionMyMoto = 'Mi Moto';
  static const String sectionProblem = 'Describe el problema';
  static const String sectionPhotos = 'Adjuntar fotos (opcional)';
  static const String sectionServiceType = 'Tipo de servicio requerido';
  static const String sectionPreview = 'Vista previa del mensaje';

  // Form labels
  static const String selectMotorcycle = 'Selecciona tu moto';
  static const String problemHint =
      'Escribe aquí los detalles del problema que presenta tu moto...';
  static const String noMotorcyclesMessage = 'No tienes motos registradas';

  // Buttons
  static const String sendButton = 'Enviar por WhatsApp';
  static const String addPhotoButton = 'Agregar foto';

  // Validation messages
  static const String selectMotorcycleError = 'Selecciona una moto';
  static const String describeProblemError = 'Describe el problema';
  static const String selectServiceError =
      'Selecciona al menos un tipo de servicio';

  // Success/Error messages
  static const String uploadingPhotos = 'Subiendo fotos...';
  static const String uploadSuccess = 'Fotos subidas correctamente';
  static const String uploadError = 'Error al subir fotos';
  static const String whatsappError = 'No se pudo abrir WhatsApp';

  // Photo limit
  static const int maxPhotos = 4;

  // Message preview template
  static const String msgGreeting = 'Hola';
  static const String msgDiagnosticRequest =
      'solicito un diagnóstico para mi moto:';
  static const String msgPlate = 'Placa:';
  static const String msgYear = 'Año:';
  static const String msgProblem = 'Problema:';
  static const String msgServiceType = 'Tipo de servicio:';
  static const String msgPhotosAttached = 'foto(s) adjuntadas en MotoGo.';
  static const String msgProblemPlaceholder =
      '[Aquí aparecerá la descripción del problema]';
  static const String msgServicePlaceholder = '[Selecciona tipo de servicio]';
  static const String msgNotApplicable = 'N/A';
}
