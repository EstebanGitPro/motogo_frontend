import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/login/domain/entities/person_login_entity.dart';

abstract class LoginRepository {
  Future<Either<ErrorModel, PersonEntity>> login(String email, String password);
}
