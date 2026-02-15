/// Common constants used across multiple features.
///
/// These are generic UI strings that appear in multiple places.
/// Use feature-specific constants for feature-scoped strings.
class CommonConstants {
  // Dialog buttons
  static const String cancel = 'Cancelar';
  static const String accept = 'Aceptar';
  static const String confirm = 'Confirmar';
  static const String delete = 'Eliminar';
  static const String save = 'Guardar';
  static const String retry = 'Reintentar';
  static const String back = 'Volver';
  static const String next = 'Siguiente';
  static const String close = 'Cerrar';

  // Actions
  static const String edit = 'Editar';
  static const String seeMore = 'Ver más';
  static const String activate = 'Activar';
  static const String deactivate = 'Desactivar';

  // Navigation
  static const String howToGetThere = 'Cómo llegar';
  static const String cancelRoute = 'Cancelar ruta';
  static const String openInGoogleMaps = 'Abrir en Google Maps';
  static const String startNavigation = 'Comenzar';
  static const String noLocationForNavigation =
      'No se pudo obtener tu ubicación actual';
  static const String routeError = 'No se pudo calcular la ruta';
  static const String loadingRoute = 'Calculando ruta...';
  static const String estimatedTime = 'min';
  static const String navigationDisclaimerTitle = 'Aviso de navegación';
  static const String navigationDisclaimerBody =
      'La navegación proporcionada es solo una referencia. '
      'El mapa puede contener errores o información desactualizada. '
      'Siempre respeta las señales de tránsito, semáforos y normas viales. '
      'MotoGo no se hace responsable por infracciones de tránsito.';
  static const String navigationDisclaimerAccept = 'Entendido';

  // Image picker
  static const String takePhoto = 'Tomar foto';
  static const String chooseFromGallery = 'Elegir de galería';

  // Form
  static const String unsavedChangesTitle = 'Cambios sin guardar';
  static const String continueEditing = 'Continuar editando';
  static const String exitWithoutSaving = 'Salir sin guardar';

  // Location
  static const String locationPermissionBanner =
      'Activa tu ubicación para ver talleres cercanos';

  // Empty states
  static const String noBrandsAvailable = 'No hay marcas disponibles';
}
