import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register_person/domain/entities/register_person_entity.dart';

abstract class RegisterPersonRepository {
  Future<Either<ErrorModel, PersonEntity>> savePerson(
    String identityNumber,
    String firstName,
    String lastName,
    String? secondLastName,
    String email,
    String phoneNumber,
    String password,
    String role,
  );
}
