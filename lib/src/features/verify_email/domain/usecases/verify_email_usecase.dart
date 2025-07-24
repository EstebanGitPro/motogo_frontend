import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/features/verify_email/domain/repositories/email_verification_repository.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';

class VerifyEmailUseCase {
  final EmailVerificationRepository repository;

  VerifyEmailUseCase({required this.repository});

  Future<Either<ErrorModel, bool>> call(String email) async {
    return await repository.verifyEmail(email);
  }
}
