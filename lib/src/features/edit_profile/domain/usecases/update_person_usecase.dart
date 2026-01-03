import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/user/domain/entities/user_entity.dart';
import 'package:motogo_frontend/src/core/user/domain/repositories/user_session_repository.dart';

/// Usecase para actualizar los datos del usuario actual.
/// Usa el UserSessionRepository centralizado.
/// Retorna el mensaje de éxito del backend.
class UpdatePersonUsecase {
  const UpdatePersonUsecase(this._repo);
  final UserSessionRepository _repo;

  Future<Either<ErrorModel, String>> call(UserEntity user) =>
      _repo.updateCurrentUser(user);
}
