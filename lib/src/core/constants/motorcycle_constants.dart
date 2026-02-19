import 'person_constants.dart';

/// Constants for the Motorcycle module (MOTORCYCLIST role).
///
/// Use these constants instead of hardcoded strings for better maintainability.
class MotorcycleConstants {
  // Page titles
  static const String userHomeTitle = 'MotoGo';
  static const String registerMotorcycleTitle = 'Registrar Motocicleta';
  static const String myMotorcyclesTitle = 'Mis Motocicletas';

  // Header section
  static const String basicInfoTitle = 'Información Básica';
  static const String basicInfoSubtitle =
      'Registra los datos de tu motocicleta';

  // Dynamic messages
  static String invalidYearRange(int maxYear) => 'Año inválido (1950-$maxYear)';

  // Menu items
  static const String menuHome = 'Inicio';
  static const String menuMyMotorcycles = 'Mis Motocicletas';
  static const String menuEditProfile = 'Editar Perfil';
  static const String menuChangePassword = 'Cambiar Contraseña';
  static const String menuDeleteAccount = PersonConstants.deleteAccountLabel;
  static const String menuLogout = 'Cerrar Sesión';
  static const String menuAbout = 'Acerca de';

  // Promotional card (Option C)
  static const String promoCardTitle = '¡Registra tu primera moto!';
  static const String promoCardSubtitle =
      'Para recibir diagnósticos y cotizaciones personalizadas.';
  static const String promoCardButton = 'REGISTRAR';

  // Search bar
  static const String searchPlaceholder = 'Buscar talleres o tiendas';
  static const String searchNoResults = 'No se encontraron sedes';
  static const String searchClearTooltip = 'Limpiar búsqueda';

  // Filter chips
  static const String filterAll = 'Todos';
  static const String filterWorkshop = 'Taller';
  static const String filterStore = 'Tienda';
  static const String filterBestRated = 'Mejor Calificados';

  // Filter Bottom Sheet
  static const String filterButton = 'Filtros';
  static const String filterTitle = 'Filtros';
  static const String filterBrandSection = 'Marca';
  static const String filterDisplacementSection = 'Cilindraje';
  static const String filterApply = 'Aplicar';
  static const String filterClear = 'Limpiar';
  static const String filterLoadingBrands = 'Cargando marcas...';
  static const String filterLoadingDisplacements = 'Cargando cilindrajes...';

  // Drawer header
  static const String drawerTitle = 'Menú Principal';

  // Register form labels
  static const String licensePlateLabel = 'Placa';
  static const String licensePlateHint = 'Ej: ABC35E';
  static const String yearLabel = 'Año';
  static const String yearHint = 'Ej: 2023';
  static const String currentMileageLabel = 'Kilómetros Actuales';
  static const String currentMileageHint = 'Ej: 5000';
  static const String ownerNotesLabel = 'Notas personales';
  static const String ownerNotesHint = 'Ej: Recién reparada, llantas nuevas...';
  static const String brandLabel = 'Marca';
  static const String brandHint = 'Selecciona una marca';
  static const String lineLabel = 'Línea';
  static const String lineHint = 'Selecciona una línea';

  // Validation messages
  static const String licensePlateRequired = 'La placa es requerida';
  static const String licensePlateInvalid =
      'Formato inválido. Moto: ABC12D, Carro: ABC123';

  // Button texts
  static const String registerButton = 'Registrar Motocicleta';
  static const String cancelButton = 'Cancelar';

  // Loading messages
  static const String loadingMotorcycles = 'Cargando motocicletas...';
  static const String registeringMotorcycle = 'Registrando motocicleta...';

  // Success messages (fallbacks, backend message takes precedence)
  static const String motorcycleRegisteredSuccess =
      'Motocicleta registrada exitosamente';

  // Error messages
  static const String errorLoadingMotorcycles = 'Error al cargar motocicletas';
  static const String errorRegisteringMotorcycle =
      'Error al registrar motocicleta';

  // Empty state
  static const String noMotorcyclesFound = 'No tienes motocicletas registradas';
  static const String noMotorcyclesSubtitle =
      'Registra tu primera moto para comenzar';

  // Confirmation dialogs
  static const String confirmLogoutTitle = 'Cerrar Sesión';
  static const String confirmLogoutMessage =
      '¿Estás seguro de que quieres cerrar sesión?';

  // Reference selector
  static const String selectReferenceOptional = 'Seleccionar referencia';
  static const String searchBrandOrModel = 'Buscar marca o modelo...';
  static const String noReferencesFound = 'No se encontraron referencias';
  static const String retryButton = 'Reintentar';
  static const String noCategory = 'Sin categoría';

  // Search motorcycle by plate (HU47)
  static const String menuSearchByPlate = 'Buscar Moto por Placa';
  static const String searchByPlateTitle = 'Buscar por Placa';
  static const String searchByPlateHint = 'Ej: ABC12D';
  static const String searchByPlateButton = 'Buscar';
  static const String searchByPlateNoResults =
      'No se encontró ninguna moto con esa placa';
  static const String searchByPlateLoading = 'Buscando...';

  // Diagnostics section in plate lookup (workshop view)
  static const String diagnosticsSectionTitle = 'Diagnósticos';
  static const String diagnosticProblemLabel = 'Problema reportado';
  static const String diagnosticSolutionLabel = 'Solución propuesta';
  static const String diagnosticDateLabel = 'Fecha';
  static const String diagnosticNoDiagnostics =
      'No hay diagnósticos registrados';
  static const String diagnosticPendingSolution = 'Pendiente de solución';
  static const String diagnosticEvidenceLabel = 'Evidencia fotográfica';

  // Motorcycle Evidence Gallery (workshop view)
  static const String motorcycleEvidenceTitle = 'Galería de evidencias';
  static const String motorcycleNoEvidence =
      'No hay evidencias fotográficas registradas';

  // Editable solution field (workshop view)
  static const String solutionHint = 'Escriba la solución propuesta';
  static const String solutionSaveButton = 'Guardar';

  // Datasource fallback errors
  static const String parseError =
      'No se encontró información de la motocicleta';
  static const String invalidServerResponse = 'Respuesta inválida del servidor';

  // Motorcycle detail spec labels
  static const String yearDetailLabel = 'Año';
  static const String mileageDetailLabel = 'Kilometraje';
  static const String categoryDetailLabel = 'Categoría';
  static const String engineDisplacementLabel = 'Cilindraje';

  // Profile image (HU36)
  static const String profileImageLabel = 'Imagen de tu Moto';
  static const String profileImageHint = 'Toca para cambiar la imagen';
  static const String profileImageUploadError = 'Error al subir imagen';

  // Edit Motorcycle page
  static const String editMotorcycleTitle = 'Editar Moto';
  static const String saveChangesButton = 'Guardar Cambios';
  static const String plateReadonlyMessage = 'La placa no se puede modificar';
  static const String yearOptionalLabel = 'Año (opcional)';
  static const String mileageOptionalLabel = 'Kilometraje actual (opcional)';
  static const String notesOptionalLabel = 'Notas (opcional)';
  static const String notesOptionalHint = 'Ej: Mi moto del trabajo';
  static const String invalidYear = 'Ingresa un año válido';
  static const String invalidMileage = 'Ingresa un kilometraje válido';

  // Delete motorcycle dialog
  static const String deleteMotorcycleTitle = 'Eliminar Moto';
  static const String deleteMotorcycleButton = 'Eliminar';

  // Menu items (User Home)
  static const String menuMyMotorcycle = 'Mi Moto';

  // Services Navigation Card
  static const String servicesCardTitle = 'Servicios';
  static const String servicesCardSubtitle =
      'Ver servicios registrados de esta motocicleta';

  // Motorcycle History (Service History)
  static const String motorcycleHistoryTitle = 'Historial de Servicios';
  static const String noServiceHistory = 'Aún no hay servicios registrados';
  static const String noServiceHistorySubtitle =
      'Cuando el taller registre servicios para esta moto, aparecerán aquí.';
  static const String quotedPriceLabel = 'Cotización';
  static const String finalPriceLabel = 'Precio Final';
  static const String representativeNotesLabel = 'Nota';
  static const String diagnosticRefLabel = 'Diagnóstico';
  static const String statusRequested = 'Solicitado';
  static const String statusInProgress = 'En Proceso';
  static const String statusCompleted = 'Finalizado';
  static const String statusCancelled = 'Cancelado';
  static const String serviceDetailTitle = 'Detalle del Servicio';
  static const String servicesPerformedLabel = 'Servicios Realizados';
  static const String branchLabel = 'Sede';

  // Service Status Transitions
  static const String startServiceButton = 'Iniciar Servicio';
  static const String finalizeServiceButton = 'Finalizar Servicio';
  static const String cancelServiceButton = 'Cancelar Servicio';
  static const String deleteServiceButton = 'Eliminar Servicio';
  static const String deleteServiceConfirmation =
      '¿Estás seguro de que deseas eliminar este servicio? Esta acción no se puede deshacer.';
  static const String transitionHistoryTitle = 'Historial de Cambios';
  static const String statusPending = 'Pendiente';

  // Completed Service Registration (Representative)
  static const String registerServiceButton = 'Registrar Servicio';
  static const String registerServiceTitle = 'Registrar Servicio';
  static const String selectBranchLabel = 'Seleccionar Sede';
  static const String selectBranchHint = 'Elige una sede';
  static const String selectServicesLabel = 'Servicios Realizados';
  static const String selectServicesHint = 'Selecciona los servicios';
  static const String registerQuotedPriceLabel = 'Cotización';
  static const String registerQuotedPriceHint = 'Ej: 185000';
  static const String registerFinalPriceLabel = 'Precio Final';
  static const String registerFinalPriceHint = 'Ej: 175000';
  static const String registerNotesLabel = 'Notas del Representante';
  static const String registerNotesHint =
      'Ej: Se realizó cambio de aceite y revisión general...';
  static const String serviceRegisteredSuccess =
      'Servicio registrado exitosamente';
  static const String serviceRegistrationError = 'Error al registrar servicio';
  static const String loadingBranches = 'Cargando sedes...';
  static const String loadingServices = 'Cargando servicios...';
  static const String noBranchesAvailable = 'No tienes sedes registradas';
  static const String noServicesAvailable =
      'Esta sede no tiene servicios asociados';
  static const String selectAtLeastOneService =
      'Selecciona al menos un servicio';
  static const String registeringService = 'Registrando servicio...';

  // Pending Services Alert (workshop view)
  static const String pendingServicesTitle = 'Servicios Pendientes';
  static const String pendingServicesSubtitle =
      'Esta motocicleta tiene servicios activos en tu sede';
  static const String goToServiceDetail = 'Ver Detalle';
  static const String registerServiceSubtitle =
      'Registrar un servicio para esta motocicleta';
  static const String registerBlockedSubtitle =
      'Gestiona los servicios pendientes antes de registrar uno nuevo';

  // Service Rating section (FINALIZADO)
  static const String rateServicesTitle = 'Calificar Servicios';
  static const String rateItemButton = 'Calificar';
  static const String alreadyRatedLabel = 'Calificado';

  // Service Editing (workshop / representative)
  static const String editServiceTitle = 'Editar Servicio';
  static const String editServiceSave = 'Guardar Cambios';
  static const String editQuotedPriceLabel = 'Cotización';
  static const String editQuotedPriceHint = 'Ej: 185000';
  static const String editFinalPriceLabel = 'Precio Final';
  static const String editFinalPriceHint = 'Ej: 175000';
  static const String editNotesLabel = 'Notas del Representante';
  static const String editNotesHint = 'Observaciones sobre el servicio...';
  static const String finalizePriceTitle = 'Precio Final del Servicio';
  static const String finalizePriceMessage =
      '¿Deseas asignar un precio final antes de finalizar?';
  static const String finalizePriceConfirm = 'Finalizar';
  static const String finalizePriceSkip = 'Sin precio';
}
