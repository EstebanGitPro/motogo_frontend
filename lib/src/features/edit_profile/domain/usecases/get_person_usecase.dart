import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/user/domain/entities/user_entity.dart';
import 'package:motogo_frontend/src/core/user/domain/repositories/user_session_repository.dart';

/// Usecase para obtener los datos del usuario actual.
/// Usa el UserSessionRepository centralizado.
class GetPersonUsecase {
  const GetPersonUsecase(this._repo);
  final UserSessionRepository _repo;

  Future<Either<ErrorModel, UserEntity>> call() => _repo.getCurrentUser();
}
