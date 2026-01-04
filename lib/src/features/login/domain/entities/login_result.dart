import 'package:motogo_frontend/src/core/user/domain/entities/user_entity.dart';

/// Resultado del login que incluye el usuario y el mensaje del backend.
class LoginResult {
  final UserEntity user;
  final String message;
  final String code;

  const LoginResult({
    required this.user,
    required this.message,
    required this.code,
  });
}
