import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/password_recovery/domain/repositories/code_validation_repository.dart';

class ValidateCodeUseCase {
  final CodeValidationRepository repository;

  ValidateCodeUseCase(this.repository);

  Future<Either<ErrorModel, bool>> call(String code) async {
    return repository.validateCode(code);
  }
}
