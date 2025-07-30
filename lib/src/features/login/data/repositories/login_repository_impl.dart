import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/login/data/datasources/login_data_source.dart';
import 'package:motogo_frontend/src/features/login/domain/entities/person_login_entity.dart';
import 'package:motogo_frontend/src/features/login/domain/repositories/login_repository.dart';

class LoginRepositoryImpl implements LoginRepository {
  final LoginDataSource dataSource;

  LoginRepositoryImpl(this.dataSource);

  @override
  Future<Either<ErrorModel, PersonEntity>> login(
    String email,
    String password,
  ) async {
    final result = await dataSource.loginPerson(email, password);
    return result;
  }
}
