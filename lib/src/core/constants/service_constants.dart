/// Constants for the services feature.
///
/// Use these constants instead of hardcoded strings for better maintainability.
class ServiceConstants {
  // Page titles
  static const String servicesManagementTitle = 'Gestión de Servicios';

  // Filter chips
  static const String filterAll = 'Todos';
  static const String filterMaintenance = 'Mantenimiento';
  static const String filterRepair = 'Reparación';
  static const String filterTires = 'Llantas';
  static const String filterDiagnostics = 'Diagnóstico';
  static const String filterAesthetics = 'Estética';
  static const String filterAccessories = 'Accesorios';
  static const String filterElectrical = 'Eléctrico';
  static const String filterLegal = 'Legal';

  // Search
  static const String searchPlaceholder = 'Buscar servicios...';

  // Service card
  static const String lastUpdated = 'Última actualización:';
  static const String serviceActive = 'Activo';
  static const String serviceInactive = 'Inactivo';

  // Loading messages
  static const String loadingServices = 'Cargando servicios...';
  static const String loadingBranchServices =
      'Cargando servicios de la sede...';

  // Error messages
  static const String errorLoadingServices = 'Error al cargar los servicios';
  static const String errorLoadingBranchServices =
      'Error al cargar los servicios de la sede';
  static const String errorAssociatingService = 'Error al asociar el servicio';
  static const String errorDissociatingService =
      'Error al desasociar el servicio';

  // Success messages
  static const String serviceAssociated = 'Servicio asociado correctamente';
  static const String serviceDissociated = 'Servicio desasociado correctamente';

  // Empty state
  static const String noServicesFound = 'No se encontraron servicios';
  static const String noServicesInCategory =
      'No hay servicios en esta categoría';

  // Toggle labels
  static const String associateService = 'Asociar servicio';
  static const String dissociateService = 'Desasociar servicio';

  // Feature not available
  static const String featurePending =
      'Esta funcionalidad estará disponible próximamente';

  /// Returns all service types as a list for filter chips
  static List<String> get allServiceTypes => [
    filterAll,
    filterMaintenance,
    filterRepair,
    filterTires,
    filterDiagnostics,
    filterAesthetics,
    filterAccessories,
    filterElectrical,
    filterLegal,
  ];

  /// Returns service types without "Todos" (for API filtering)
  static List<String> get serviceTypesForApi => [
    filterMaintenance,
    filterRepair,
    filterTires,
    filterDiagnostics,
    filterAesthetics,
    filterAccessories,
    filterElectrical,
    filterLegal,
  ];
}
