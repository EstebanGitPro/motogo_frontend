import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/password_recovery/data/datasources/code_validation_datasource.dart';
import 'package:motogo_frontend/src/features/password_recovery/domain/repositories/code_validation_repository.dart';

class CodeValidationRepositoryImpl implements CodeValidationRepository {
  final CodeValidationDataSource dataSource;

  CodeValidationRepositoryImpl(this.dataSource);

  @override
  Future<Either<ErrorModel, bool>> validateCode(String code) async {
    final isValid = await dataSource.validateCode(code);
    return isValid;
  }
}
