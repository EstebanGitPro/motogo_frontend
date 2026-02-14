/// Constants for the branch detail feature.
///
/// Use these constants instead of hardcoded strings for better maintainability.
class BranchDetailConstants {
  // Page title
  static const String pageTitle = 'Detalle del Taller';

  // Sections
  static const String sectionContact = 'Contacto';
  static const String sectionSchedule = 'Horario de Atención';
  static const String sectionServices = 'Servicios Disponibles';
  static const String sectionDisplacementRanges = 'Cilindrajes';

  // Status labels
  static const String statusOpen = 'Abierto ahora';
  static const String statusClosed = 'Cerrado';
  static const String statusClosedToday = 'Cerrado hoy';
  static const String statusClosedException = 'Cerrado (Excepción)';

  // Days of the week (with format: "Day: HH:mm - HH:mm")
  static const String dayToday = '(Hoy)';
  static const String dayClosed = 'Cerrado';

  // Contact
  static const String phoneNotAvailable = 'No disponible';

  // Buttons
  static const String buttonHowToGet = 'Cómo Llegar';
  static const String buttonSendDiagnostic = 'Pedir Diagnóstico';

  // Loading messages
  static const String loadingDetail = 'Cargando información...';
  static const String loadingServices = 'Cargando servicios...';
  static const String loadingSchedule = 'Cargando horarios...';

  // Error messages
  static const String errorLoadingDetail = 'Error al cargar la información';
  static const String errorLoadingServices = 'Error al cargar los servicios';
  static const String errorLoadingSchedule = 'Error al cargar los horarios';

  // Empty states
  static const String noServicesAvailable = 'No hay servicios disponibles';
  static const String noScheduleAvailable = 'Horario no disponible';
  static const String noDisplacementRanges = 'No especificados';

  // Upcoming feature
  static const String featureComingSoon = 'Próximamente';

  // Service price format
  static const String priceFormat = '\$';

  // View reviews
  static const String viewReviews = 'Ver Reseñas';

  // Type labels
  static const String typeWorkshop = 'TALLER';
  static const String typeStore = 'TIENDA';

  // Datasource fallback messages
  static const String workshopNotFound =
      'No se encontró información del taller';

  // Navigation
  static const String buttonBack = 'Volver';

  // Address fallback
  static const String addressNotAvailable = 'Dirección no disponible';
}
