import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/constants/change_password_constants.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/user/user_session_manager.dart';
import 'package:motogo_frontend/src/features/change_password/data/datasources/change_password_data_source.dart';
import 'package:motogo_frontend/src/features/change_password/domain/repositories/change_password_repository.dart';

class ChangePasswordRepositoryImpl implements ChangePasswordRepository {
  final ChangePasswordDataSource _dataSource;

  ChangePasswordRepositoryImpl(this._dataSource);

  @override
  Future<Either<ErrorModel, String>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = UserSessionManager.instance.accessToken;

    if (token == null) {
      return Left(ErrorModel(message: ChangePasswordConstants.noActiveSession));
    }

    return _dataSource.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      token: token,
    );
  }
}
