import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/change_password/domain/repositories/change_password_repository.dart';

/// UseCase para cambiar la contraseña del usuario autenticado.
class ChangePasswordUseCase {
  final ChangePasswordRepository _repository;

  ChangePasswordUseCase(this._repository);

  /// Ejecuta el cambio de contraseña.
  /// Retorna el mensaje de éxito del backend o un ErrorModel.
  Future<Either<ErrorModel, String>> call({
    required String currentPassword,
    required String newPassword,
  }) {
    return _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
