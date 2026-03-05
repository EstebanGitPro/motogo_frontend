/// Constants for person-related UI strings.
class PersonConstants {
  PersonConstants._();

  // Shared labels
  static const String deleteAccountLabel = 'Eliminar Cuenta';

  // Delete Account Dialog
  static const String deleteAccountTitle = deleteAccountLabel;
  static const String deleteAccountWarning =
      'Esta acción es IRREVERSIBLE.\n\n'
      'Al eliminar tu cuenta:\n'
      '• Se eliminarán todas tus sedes\n'
      '• Se perderá toda tu información\n'
      '• No podrás recuperar tu cuenta';
  static const String deleteAccountConfirmPrompt =
      'Escribe "eliminar" para confirmar:';
  static const String deleteAccountConfirmWord = 'eliminar';
  static const String deleteAccountButton = deleteAccountLabel;
  static const String deleteAccountFallbackSuccess =
      'Cuenta eliminada exitosamente';

  // Menu
  static const String deleteAccountMenuTitle = deleteAccountLabel;

  // Email verification page
  static const String verificationTitle = 'Revisa tu correo electrónico';
  static const String verificationSentMessage =
      'Enviamos un enlace de verificación a:';
  static const String verificationSpamNote =
      'El correo puede tardar unos minutos en llegar. '
      'Revisa tu carpeta de spam si no lo ves.';
  static const String redirectingCountdownPrefix = 'Redirigiendo al login en ';
  static const String redirectingCountdownSuffix = ' segundos...';
  static const String redirecting = 'Redirigiendo...';
  static const String goToLoginNow = 'Ir al login ahora';
}
