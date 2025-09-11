import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/password_recovery/domain/repositories/password_reset_repository.dart';

class PasswordResetUseCase {
  final PasswordResetRepository repository;

  PasswordResetUseCase(this.repository);

  Future<Either<ErrorModel, void>> call(String code, String newPassword) async {
    try {
      return await repository.resetPassword(code, newPassword);
    } catch (e) {
      return Left(ErrorModel(message: e.toString()));
    }
  }
}
