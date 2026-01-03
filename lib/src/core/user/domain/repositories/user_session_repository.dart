import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/user/domain/entities/user_entity.dart';

/// Repository abstracto para operaciones de sesión del usuario.
abstract class UserSessionRepository {
  /// Obtiene el usuario actual desde el backend
  Future<Either<ErrorModel, UserEntity>> getCurrentUser();

  /// Actualiza los datos del usuario actual
  /// Retorna el mensaje de éxito del backend
  Future<Either<ErrorModel, String>> updateCurrentUser(UserEntity user);
}
