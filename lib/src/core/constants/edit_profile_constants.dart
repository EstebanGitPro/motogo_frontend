/// Constants for the edit profile feature.
class EditProfileConstants {
  EditProfileConstants._();

  // Page
  static const String pageTitle = 'Editar mis datos';
  static const String loadingProfile = 'Cargando datos del perfil...';
  static const String pendingChanges = 'Cambios pendientes';
  static const String refreshFromServer = 'Actualizar desde servidor';
  static const String noChanges = 'No hay cambios para guardar';
  static const String updatePrompt = 'Actualiza tu información personal';
  static const String cacheNotice =
      'Datos desde caché - toca el ícono de actualizar para obtener la versión más reciente';
  static const String saving = 'Guardando...';
  static const String saveChanges = 'Guardar cambios';

  // Form labels
  static const String identityNumberLabel = 'Número de identificación';
  static const String firstNameLabel = 'Nombres';
  static const String lastNameLabel = 'Primer apellido';
  static const String secondLastNameLabel = 'Segundo apellido (opcional)';
  static const String emailLabel = 'Correo electrónico';
  static const String phoneLabel = 'Número de teléfono';

  // Unsaved changes dialog
  static const String unsavedChangesMessage =
      'Tienes cambios sin guardar. ¿Deseas salir sin guardar?';
}
