import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/user/data/datasources/user_session_data_source.dart';
import 'package:motogo_frontend/src/core/user/data/models/user_model.dart';
import 'package:motogo_frontend/src/core/user/domain/entities/user_entity.dart';
import 'package:motogo_frontend/src/core/user/domain/repositories/user_session_repository.dart';
import 'package:motogo_frontend/src/core/user/user_session_manager.dart';

/// Implementación del repository de sesión del usuario.
/// Usa el UserSessionManager para obtener el token y actualizar el cache.
class UserSessionRepositoryImpl implements UserSessionRepository {
  final UserSessionDataSource _dataSource;

  UserSessionRepositoryImpl(this._dataSource);

  @override
  Future<Either<ErrorModel, UserEntity>> getCurrentUser() async {
    final token = await UserSessionManager.instance.getAccessToken();

    if (token == null) {
      return Left(
        ErrorModel(
          message:
              'No se encontró token de autenticación. Por favor, inicia sesión nuevamente.',
        ),
      );
    }

    final result = await _dataSource.fetchCurrentUser(token);

    return result.fold((error) => Left(error), (user) {
      // Actualizar el cache local
      UserSessionManager.instance.updateUser(user);
      return Right(user);
    });
  }

  @override
  Future<Either<ErrorModel, String>> updateCurrentUser(UserEntity user) async {
    final token = await UserSessionManager.instance.getAccessToken();

    if (token == null) {
      return Left(
        ErrorModel(
          message:
              'No se encontró token de autenticación. Por favor, inicia sesión nuevamente.',
        ),
      );
    }

    final userModel = UserModel.fromEntity(user);
    final result = await _dataSource.updateCurrentUser(userModel, token);

    return result.fold((error) => Left(error), (message) {
      // Actualizar el cache local con los nuevos datos
      UserSessionManager.instance.updateUser(userModel);
      return Right(message);
    });
  }
}
