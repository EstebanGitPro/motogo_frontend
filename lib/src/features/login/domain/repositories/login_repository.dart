import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/login/domain/entities/login_result.dart';

/// Repository abstracto para el proceso de login.
abstract class LoginRepository {
  Future<Either<ErrorModel, LoginResult>> login(String email, String password);
}
