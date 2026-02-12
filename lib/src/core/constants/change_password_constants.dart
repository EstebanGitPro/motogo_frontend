/// Constantes para el feature de cambio de contraseña.
abstract class ChangePasswordConstants {
  // AppBar
  static const String pageTitle = 'Cambiar Contraseña';

  // Descripción
  static const String description =
      'Ingresa tu contraseña actual y define una nueva contraseña para tu cuenta.';

  // Labels de campos
  static const String currentPasswordLabel = 'Contraseña actual';
  static const String newPasswordLabel = 'Nueva contraseña';
  static const String confirmPasswordLabel = 'Confirmar nueva contraseña';

  // Helper text
  static const String passwordRequirementsHelper =
      'Mínimo 8 caracteres, una mayúscula, una minúscula y un número';

  // Mensajes de validación
  static const String currentPasswordRequired =
      'Por favor ingresa tu contraseña actual';
  static const String newPasswordRequired =
      'Por favor ingresa una nueva contraseña';
  static const String passwordMinLength =
      'La contraseña debe tener al menos 8 caracteres';
  static const String passwordRequirements =
      'Debe incluir mayúscula, minúscula y número';
  static const String confirmPasswordRequired =
      'Por favor confirma tu nueva contraseña';
  static const String passwordsDoNotMatch = 'Las contraseñas no coinciden';

  // Botón
  static const String submitButton = 'Cambiar Contraseña';

  // Datasource/Repository fallback messages
  static const String noActiveSession = 'No hay sesión activa';
}
