import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/password_recovery/data/datasources/password_reset_data_source.dart';
import 'package:motogo_frontend/src/features/password_recovery/domain/repositories/password_reset_repository.dart';

class PasswordResetRepositoryImpl implements PasswordResetRepository {
  final PasswordResetDataSource dataSource;

  PasswordResetRepositoryImpl(this.dataSource);

  @override
  Future<Either<ErrorModel, void>> resetPassword(
    String code,
    String newPassword,
  ) async {
    return await dataSource.resetPassword(code, newPassword);
  }
}
