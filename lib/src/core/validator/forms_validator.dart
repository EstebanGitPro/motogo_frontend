

import 'package:motogo_frontend/src/core/errors/error_messages.dart';

class FormValidators {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return ValidationMessages.emailRequired;
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return ValidationMessages.emailInvalid;
    }
    
    return null;
  }
  
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return ValidationMessages.passwordRequired;
    }
    
    if (password.length < 6) {
      return ValidationMessages.passwordTooShort;
    }
    
    
    return null;
  }
  
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }
}
