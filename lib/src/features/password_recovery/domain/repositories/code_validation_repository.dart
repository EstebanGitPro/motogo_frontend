import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';

abstract class CodeValidationRepository {
  Future<Either<ErrorModel, bool>> validateCode(String code);
}
