import 'package:motogo_frontend/src/core/errors/exceptions.dart';

class RegisterValidationException extends AppException {
  const RegisterValidationException(super.message);
}

class EmailAlreadyExistsException extends AppException {
  const EmailAlreadyExistsException() : super('El email ya está registrado');
}

class IdentityNumberExistsException extends AppException {
  const IdentityNumberExistsException()
    : super('El número de identificación ya existe');
}

class WeakPasswordException extends AppException {
  const WeakPasswordException() : super('La contraseña es muy débil');
}
