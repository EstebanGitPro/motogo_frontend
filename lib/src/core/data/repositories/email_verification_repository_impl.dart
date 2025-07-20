import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/data/datasources/email_verification_remote_data_source.dart';
import 'package:motogo_frontend/src/core/domain/repositories/email_verification_repository.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';

class EmailVerificationRepositoryImpl implements EmailVerificationRepository {
  final EmailVerificationRemoteDataSource remoteDataSource;

  EmailVerificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<ErrorModel, bool>> verifyEmail(String email) async {
    return await remoteDataSource.verifyEmail(email);
  }
}
