import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/login/data/datasources/login_data_source.dart';

import 'package:motogo_frontend/src/features/login/domain/entities/person_entity.dart';
import 'package:motogo_frontend/src/features/login/domain/repositories/login_repository.dart';

class LoginRepositoryImpl implements LoginRepository {
  final LoginDataSource dataSource;

  LoginRepositoryImpl(this.dataSource);

  @override
  Future<Either<ErrorModel, PersonEntity>> login(
    String email,
    String password,
  ) async {
    try {
      return await dataSource.loginPerson(email, password);
    } catch (error) {
      if (error is ErrorModel) {
        throw Exception('Error de autenticación: ${error.message}');
      }

      throw Exception('Error en login: ${error.toString()}');
    }
  }
}
