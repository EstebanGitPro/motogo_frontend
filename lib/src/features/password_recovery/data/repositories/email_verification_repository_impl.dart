import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/password_recovery/data/datasources/email_verification_datasource.dart';
import 'package:motogo_frontend/src/features/password_recovery/domain/repositories/email_verification_repository.dart';

class EmailRecoveryVerificationRepositoryImpl
    implements EmailRecoveryVerificationRepository {
  final EmailRecoveryVerificationDataSource dataSource;

  EmailRecoveryVerificationRepositoryImpl(this.dataSource);

  @override
  Future<Either<ErrorModel, bool>> verifyEmail(String email) async {
    final exists = await dataSource.verifyEmail(email);
    return exists;
  }
}
