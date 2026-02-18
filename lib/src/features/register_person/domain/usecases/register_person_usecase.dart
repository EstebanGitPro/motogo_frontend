import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register_person/domain/entities/register_person_entity.dart';
import 'package:motogo_frontend/src/features/register_person/domain/entities/register_person_params.dart';
import 'package:motogo_frontend/src/features/register_person/domain/repositories/register_person_repository.dart';

class RegisterPersonUseCase {
  final RegisterPersonRepository registerPersonRepository;
  RegisterPersonUseCase(this.registerPersonRepository);

  Future<Either<ErrorModel, PersonEntity>> call(
    RegisterPersonParams params,
  ) async {
    return await registerPersonRepository.savePerson(params);
  }
}
