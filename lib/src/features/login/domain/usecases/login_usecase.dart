import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/login/domain/entities/person_entity.dart';
import 'package:motogo_frontend/src/features/login/domain/repositories/login_repository.dart';

class LoginUseCase {
  final LoginRepository repository;

  LoginUseCase(this.repository);

  Future<Either<ErrorModel, PersonEntity>> call(
    String email,
    String password,
  ) async {
    return await repository.login(email, password);
  }
}
