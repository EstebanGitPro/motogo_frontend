import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/login/domain/entities/person_login_entity.dart';
import 'package:motogo_frontend/src/features/login/domain/repositories/login_repository.dart';

class LoginUseCase {
  final LoginRepository repository;

  LoginUseCase(this.repository);

  Future<Either<ErrorModel, PersonEntity>> call({
    required String email,
    required String password,
  }) async {
    return await repository.login(email, password);
  }
}
