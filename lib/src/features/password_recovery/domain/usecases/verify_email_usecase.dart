import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/password_recovery/domain/repositories/email_verification_repository.dart';

class VerifyRecoveryEmailUseCase {
  final EmailRecoveryVerificationRepository repository;

  VerifyRecoveryEmailUseCase(this.repository);

  Future<Either<ErrorModel, bool>> call(String email) async {
    return await repository.verifyEmail(email);
  }
}
