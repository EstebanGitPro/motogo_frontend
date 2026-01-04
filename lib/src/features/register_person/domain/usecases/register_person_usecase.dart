import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register_person/domain/entities/register_person_entity.dart';
import 'package:motogo_frontend/src/features/register_person/domain/repositories/register_person_repository.dart';

class RegisterPersonUseCase {
  final RegisterPersonRepository registerPersonRepository;
  RegisterPersonUseCase(this.registerPersonRepository);

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
    return await registerPersonRepository.savePerson(
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
