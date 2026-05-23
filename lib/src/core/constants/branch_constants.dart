/// Constants for the branches feature.
///
/// Use these constants instead of hardcoded strings for better maintainability.
class BranchConstants {
  // Form labels
  static const String establishmentTypeLabel = 'Tipo de Establecimiento';
  static const String branchNameLabel = 'Nombre de la Sede';
  static const String branchNameHint = 'Ej: MotosGo Centro';
  static const String addressLabel = 'Dirección';
  static const String addressHint = 'Ej: Calle 123 #45-67';
  static const String searchPlaceholder = 'Buscar sedes';

  // Loading messages
  static const String loadingTypes = 'Cargando tipos...';
  static const String loadingBrands = 'Cargando marcas...';
  static const String loadingDepartments = 'Cargando departamentos...';
  static const String loadingCities = 'Cargando ciudades...';
  static const String loadingBranches = 'Cargando sedes...';

  // Error messages
  static const String errorLoadingTypes = 'Error al cargar tipos';
  static const String errorLoadingBrands = 'Error al cargar marcas';
  static const String errorLoadingDepartments = 'Error al cargar departamentos';
  static const String errorLoadingCities = 'Error al cargar ciudades';
  static const String errorLoadingBranches = 'Error al cargar sedes';

  // Validation messages
  static const String typeRequired = 'Por favor selecciona un tipo';
  static const String brandRequired = 'Por favor selecciona al menos una marca';
  static const String locationRequired =
      'Por favor selecciona departamento y ciudad';
  static const String branchNameRequired =
      'Por favor ingresa el nombre de la sede';
  static const String addressRequired = 'Por favor ingresa la dirección';

  // Status labels
  static const String statusActive = 'Activo';
  static const String statusInactive = 'Inactivo';

  // Page titles
  static const String myBranchesTitle = 'Mis Sedes';
  static const String createBranchTitle = 'Crear Sede';
  static const String editBranchTitle = 'Editar Sede';
  static const String branchPrefix = 'Sede ';

  // Button texts
  static const String createBranchButton = 'Crear Sede';
  static const String createFirstBranchButton = 'Crear mi primera sede';
  static const String uploadingImage = 'Subiendo imagen...';
  static const String cancel = 'Cancelar';
  static const String retry = 'Reintentar';

  // Empty state messages
  static const String welcomeTitle = '¡Bienvenido!';
  static const String noBranchesMessage =
      'Aún no tienes sedes registradas.\nCrea tu primera sede para empezar.';
  static const String noSearchResults = 'No se encontraron sedes';
  static const String noRegisteredBranches = 'Aún no tienes sedes registradas';
  static const String errorUploadingImage = 'Error al subir imagen';

  // Image picker
  static const String branchImageLabel = 'Imagen de la Sede';
  static const String branchImageHint = 'Toca para agregar una imagen';

  // Detail page tabs
  static const String tabServices = 'Servicios';
  static const String tabSchedule = 'Horarios';
  static const String tabLocation = 'Ubicación';
  static const String tabEdit = 'Editar';

  // Services section
  static const String sectionServices = 'Servicios';
  static const String serviceBasicMaintenance = 'Mantenimiento Básico';
  static const String serviceGeneralRepair = 'Reparación General';

  // Location tab
  static const String loadingLocation = 'Cargando ubicación...';
  static const String errorLoadingLocation = 'No se pudo cargar la ubicación';
  static const String openInMaps = 'Abrir en Maps';
  static const String locationNotAvailable = 'Ubicación no disponible';

  // Placeholders (for future tabs)
  static const String comingSoon = 'Próximamente';

  // Edit form
  static const String updateBranchButton = 'Actualizar Sede';
  static const String updatingBranch = 'Actualizando sede...';
  static const String branchUpdatedSuccess = 'Sede actualizada exitosamente';

  // Delete confirmation
  static const String deleteBranchTitle = 'Eliminar Sede';
  static const String deleteBranchConfirmMessage =
      'Esta acción no se puede deshacer. Para confirmar, escribe "eliminar" abajo:';
  static const String deleteBranchConfirmWord = 'eliminar';
  static const String deleteBranchConfirmHint = 'Escribe "eliminar"';
  static const String deleteBranchConfirmError =
      'Debes escribir "eliminar" para confirmar';
  static const String deleteBranchButton = 'Eliminar Sede';
  static const String deletingBranch = 'Eliminando sede...';
  static const String branchDeletedSuccess = 'Sede eliminada exitosamente';

  // FAB menu options
  static const String newBranchOption = 'Nueva Sede';
  static const String newFranchiseOption = 'Nueva Franquicia';
  static const String franchiseFallbackName = 'Franquicia';

  /// Maps backend establishment type codes to Spanish display labels.
  ///
  /// Used by [BranchCard] and [BranchInfoCard] to render the type chip.
  static String mapTypeToLabel(String type) {
    switch (type.toUpperCase()) {
      case 'WORKSHOP':
        return 'Taller';
      case 'STORE':
        return 'Tienda';
      case 'WORKSHOP_STORE':
        return 'Taller y Tienda';
      default:
        return type;
    }
  }
}
