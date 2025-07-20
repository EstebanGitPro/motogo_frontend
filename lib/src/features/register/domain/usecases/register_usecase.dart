import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register/domain/entities/person_entity.dart';
import 'package:motogo_frontend/src/features/register/domain/repositories/register_repository.dart';

class RegisterUseCase {
  final RegisterRepository registerRepository;
  RegisterUseCase(this.registerRepository);

  Future<Either<ErrorModel, PersonEntity>> call(
    String identityNumber,
    String firstName,
    String lastName,
    String? secondLastName,
    String email,
    String phoneNumber,
    String password,
    String role,
  ) async {
    return await registerRepository.savePerson(
      identityNumber,
      firstName,
      lastName,
      secondLastName,
      email,
      phoneNumber,
      password,
      role,
    );
  }
}
