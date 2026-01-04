/// Login feature translation keys
///
/// Use these constants instead of hardcoded strings for better maintainability
/// and easier translation management
class LoginTranslationKeys {
  // Page titles
  static const String loginTitle = 'login_title';
  static const String loginPageTitle = 'login_page_title';

  // Form labels
  static const String emailLabel = 'email_label';
  static const String passwordLabel = 'password_label';

  // Buttons
  static const String loginButton = 'login_button';
  static const String forgotPassword = 'forgot_password';
  static const String dontHaveAccount = 'dont_have_account';
  static const String register = 'register';

  // Messages
  static const String loggingIn = 'logging_in';
  static const String loginSuccess = 'login_success';
  static const String loginFailed = 'login_failed';

  // Verification dialog
  static const String verificationRequired = 'verification_required';
  static const String goToVerification = 'go_to_verification';
  static const String understood = 'understood';
  static const String emailNotVerified = 'email_not_verified_default';

  // Validation
  static const String emailRequired = 'email_required';
  static const String emailInvalid = 'email_invalid';
  static const String passwordRequired = 'password_required';
  static const String passwordTooShort = 'password_too_short';
}

/// Login feature numeric constants
class LoginConstants {
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int loginTimeoutSeconds = 30;
  static const int snackbarDurationSeconds = 3;
  static const int successSnackbarDurationSeconds = 1;
}

/// Login feature error detection constants
class LoginErrorConstants {
  // Error codes for email verification
  static const String emailNotVerifiedCode = 'EMAIL_NOT_VERIFIED';
  static const String unverifiedEmailCode = 'UNVERIFIED_EMAIL';
  static const String forbiddenCode = '403';

  // Keywords to detect in error messages
  static const List<String> verificationKeywords = [
    'verificado',
    'verificar',
    'verification',
    'verify',
    'no verificado',
  ];
}
