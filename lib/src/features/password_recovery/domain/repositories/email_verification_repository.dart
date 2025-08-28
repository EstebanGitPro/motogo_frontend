import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';

abstract class EmailRecoveryVerificationRepository {
  Future<Either<ErrorModel, bool>> verifyEmail(String email);
}
