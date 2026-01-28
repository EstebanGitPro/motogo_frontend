/// Constants for the Admin module.
///
/// Use these constants instead of hardcoded strings for better maintainability.
class AdminConstants {
  // Page titles
  static const String adminHomeTitle = 'Panel de Administración';
  static const String serviceCatalogTitle = 'Catálogo de Servicios';
  static const String editServiceTitle = 'Editar Servicio';

  // Menu items
  static const String menuHome = 'Inicio';
  static const String menuServiceCatalog = 'Catálogo de Servicios';
  static const String menuLogout = 'Cerrar Sesión';

  // Dashboard cards
  static const String cardServiceCatalog = 'Catálogo de Servicios';
  static const String cardServiceCatalogSubtitle =
      'Gestionar servicios globales';
  static const String cardFuture = 'Próximamente';
  static const String cardFutureSubtitle = 'Más opciones disponibles pronto';
  static const String cardReports = 'Reportes';
  static const String cardReportsSubtitle = 'Estadísticas y reportes';
  static const String cardUsers = 'Usuarios';
  static const String cardUsersSubtitle = 'Gestión de usuarios';
  static const String cardSettings = 'Configuración';
  static const String cardSettingsSubtitle = 'Configuración del sistema';

  // Welcome header
  static const String welcomeTitle = '¡Bienvenido, Administrador!';
  static const String welcomeSubtitle =
      'Gestiona el catálogo de servicios de MotoGo';

  // Service catalog
  static const String searchServicesPlaceholder = 'Buscar servicio...';
  static const String filterAllTypes = 'Todos los tipos';
  static const String serviceActive = 'Activo';
  static const String serviceInactive = 'Inactivo';
  static const String noServicesFound = 'No se encontraron servicios';
  static const String serviceAvailable = 'El servicio está disponible';
  static const String serviceNotAvailable = 'El servicio no está disponible';

  // Edit service form
  static const String serviceNameLabel = 'Nombre del Servicio';
  static const String serviceNameHint = 'Ej: Cambio de aceite';
  static const String serviceDescriptionLabel = 'Descripción';
  static const String serviceDescriptionHint =
      'Ej: Cambio de aceite completo...';
  static const String serviceTypeLabel = 'Tipo de Servicio';
  static const String serviceActiveLabel = 'Servicio Activo';

  // Validation messages
  static const String serviceNameRequired =
      'Por favor ingresa el nombre del servicio';
  static const String serviceTypeRequired =
      'Por favor selecciona el tipo de servicio';

  // Button texts
  static const String saveButton = 'Guardar Cambios';
  static const String cancelButton = 'Cancelar';
  static const String activateButton = 'Activar';
  static const String deactivateButton = 'Desactivar';
  static const String retryButton = 'Reintentar';
  static const String editButton = 'Editar';

  // Loading messages
  static const String loadingServices = 'Cargando servicios...';
  static const String updatingService = 'Actualizando servicio...';
  static const String activatingService = 'Activando servicio...';
  static const String deactivatingService = 'Desactivando servicio...';

  // Success messages
  static const String serviceUpdatedSuccess =
      'Servicio actualizado exitosamente';
  static const String serviceActivatedSuccess =
      'Servicio activado exitosamente';
  static const String serviceDeactivatedSuccess =
      'Servicio desactivado exitosamente';

  // Error messages
  static const String errorLoadingServices = 'Error al cargar servicios';
  static const String errorUpdatingService = 'Error al actualizar servicio';
  static const String errorActivatingService = 'Error al activar servicio';
  static const String errorDeactivatingService = 'Error al desactivar servicio';
  static const String errorParsingResponse =
      'Error al procesar respuesta del servidor';

  // Roles (lowercase, matching backend response)
  static const String roleAdmin = 'admin';
  static const String roleRepresentative = 'representative';
  static const String roleMotorcyclist = 'user';

  // Drawer header
  static const String drawerTitle = 'Menú Principal';
  static const String drawerSubtitle = 'Panel de Administración';

  // Confirmation dialogs
  static const String confirmLogoutTitle = 'Cerrar Sesión';
  static const String confirmLogoutMessage =
      '¿Estás seguro de que quieres cerrar sesión?';
  static const String confirmDeactivateTitle = 'Desactivar Servicio';
  static const String confirmDeactivateMessage =
      'Al desactivar este servicio, no estará disponible para asociar a nuevas sedes. ¿Continuar?';

  // Fallback messages
  static const String serviceActivated = 'Servicio activado';
  static const String serviceDeactivated = 'Servicio desactivado';
  static const String serviceAssociated = 'Servicio asociado';
}
