/// Constants for the Motorcycle module (MOTORCYCLIST role).
///
/// Use these constants instead of hardcoded strings for better maintainability.
class MotorcycleConstants {
  // Page titles
  static const String userHomeTitle = 'MotoGo';
  static const String registerMotorcycleTitle = 'Registrar Motocicleta';
  static const String myMotorcyclesTitle = 'Mis Motocicletas';

  // Menu items
  static const String menuHome = 'Inicio';
  static const String menuMyMotorcycles = 'Mis Motocicletas';
  static const String menuEditProfile = 'Editar Perfil';
  static const String menuChangePassword = 'Cambiar Contraseña';
  static const String menuDeleteAccount = 'Eliminar Cuenta';
  static const String menuLogout = 'Cerrar Sesión';
  static const String menuAbout = 'Acerca de';

  // Promotional card (Option C)
  static const String promoCardTitle = '¡Registra tu primera moto!';
  static const String promoCardSubtitle =
      'Para recibir diagnósticos y cotizaciones personalizadas.';
  static const String promoCardButton = 'REGISTRAR';

  // Search bar
  static const String searchPlaceholder = 'Buscar talleres o tiendas';

  // Filter chips
  static const String filterAll = 'Todos';
  static const String filterWorkshop = 'Taller';
  static const String filterStore = 'Tienda';
  static const String filterBestRated = 'Mejor Calificados';

  // Drawer header
  static const String drawerTitle = 'Menú Principal';

  // Register form labels
  static const String licensePlateLabel = 'Placa';
  static const String licensePlateHint = 'Ej: ABC123';
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
      'Formato de placa inválido (ej: ABC123)';

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
}
