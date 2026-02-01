import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';

abstract class ChangePasswordRepository {
  Future<Either<ErrorModel, String>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
