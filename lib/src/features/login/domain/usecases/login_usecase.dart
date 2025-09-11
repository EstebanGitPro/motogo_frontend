import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/login/domain/entities/person_login_entity.dart';
import 'package:motogo_frontend/src/features/login/domain/repositories/login_repository.dart';

class LoginUseCase {
  final LoginRepository repository;

  LoginUseCase(this.repository);

  Future<Either<ErrorModel, PersonEntity>> call(
    {required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) {
      return Left(ErrorModel(message: 'Los campos no pueden estar vacios'));
    }
    try {
      return await repository.login(email, password);
    } catch (e) {
      return Left(ErrorModel(message: e.toString()));
    }
  }
}

