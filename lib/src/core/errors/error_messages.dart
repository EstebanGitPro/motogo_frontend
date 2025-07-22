class ValidationMessages {

  static const String emailRequired = 'El email es requerido';
  static const String emailInvalid = 'Ingresa un email válido';
  static const String passwordRequired = 'La contraseña es requerida';
  static const String passwordTooShort = 'La contraseña debe tener al menos 8 caracteres';
  static const String passwordTooWeak = 'La contraseña debe contener al menos una mayúscula, una minúscula y un número';
  

  static const String invalidCredentials = 'Email o contraseña incorrectos';
  static const String emailNotVerified = 'Email no verificado. Hemos enviado un nuevo enlace de verificación a tu correo electrónico.';
  static const String invalidJsonFormat = 'Datos inválidos. Verifica que el email y contraseña estén correctos.';
  static const String validationError = 'Error de validación en los datos enviados';
  

  static const String networkError = 'Error de conexión. Verifica tu internet';
  static const String serverError = 'Error del servidor. Intenta más tarde';
  static const String timeoutError = 'La solicitud tardó demasiado. Intenta nuevamente';
  static const String genericError = 'Ocurrió un error inesperado';
  

  static const String loginSuccess = 'Inicio de sesión exitoso';
  static const String logoutSuccess = 'Sesión cerrada correctamente';
}