/// Constants for the franchise feature.
///
/// Use these constants instead of hardcoded strings for better maintainability.
class FranchiseConstants {
  // Page titles
  static const String createFranchiseTitle = 'Crear Franquicia';
  static const String manageFranchiseTitle = 'Gestionar Franquicia';

  // Form labels
  static const String franchiseNameLabel = 'Nombre de la franquicia';
  static const String franchiseNameHint = 'Ej: MotoMax Colombia';
  static const String descriptionLabel = 'Descripción (opcional)';
  static const String descriptionHint = 'Describe tu franquicia';

  // Section titles
  static const String associateBranchesTitle = 'Asociar Sedes';
  static const String associateBranchesSubtitle =
      'Selecciona las sedes que pertenecerán a esta franquicia';

  // Validation messages
  static const String franchiseNameRequired =
      'Por favor ingresa el nombre de la franquicia';
  static const String atLeastOneBranchRequired =
      'Debes seleccionar al menos una sede';

  // Button texts
  static const String createFranchiseButton = 'Crear Franquicia';
  static const String creatingFranchise = 'Creando franquicia...';

  // Success/Error messages
  static const String franchiseCreatedSuccess =
      'Franquicia creada exitosamente';
  static const String noBranchesAvailable = 'No tienes sedes disponibles';
  static const String noBranchesAvailableHint =
      'Primero crea al menos una sede para poder asignarla a una franquicia';

  // === ManageFranchise Page ===

  // Loading/Error states
  static const String loadingTitle = 'Cargando...';
  static const String errorTitle = 'Error';
  static const String errorLoadingFranchise = 'Error al cargar franquicia';

  // AppBar
  static const String franchisePrefix = 'Franquicia: ';

  // Menu actions
  static const String deleteFranchiseMenu = 'Eliminar franquicia';

  // Section headers
  static const String linkedBranchesSection = 'Sedes en esta franquicia';
  static const String availableBranchesSection = 'Sedes disponibles';

  // Empty states
  static const String noLinkedBranches = 'No hay sedes vinculadas';
  static const String noAvailableBranches =
      'No hay sedes disponibles para vincular';

  // Dialogs
  static const String unlinkBranchTitle = 'Desvincular sede';
  static const String unlinkBranchConfirm = '¿Deseas desvincular';
  static const String unlinkBranchSuffix = 'de esta franquicia?';
  static const String unlinkAction = 'Desvincular';
  static const String cancelAction = 'Cancelar';
  static const String saveAction = 'Guardar';

  static const String editFranchiseTitle = 'Editar franquicia';
  static const String deleteFranchiseTitle = 'Eliminar franquicia';
  static const String deleteFranchiseConfirm =
      '¿Estás seguro? Las sedes quedarán independientes.';
  static const String deleteAction = 'Eliminar';

  // Tooltip
  static const String mustHaveOneBranch = 'Debe haber al menos una sede';

  // Branch types
  static const String typeWorkshop = 'Taller';
  static const String typeStore = 'Tienda';
  static const String typeWorkshopStore = 'Taller y Tienda';
}
