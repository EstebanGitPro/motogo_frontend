import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register_person/domain/entities/register_person_entity.dart';
import 'package:motogo_frontend/src/features/register_person/domain/entities/register_person_params.dart';

abstract class RegisterPersonRepository {
  Future<Either<ErrorModel, PersonEntity>> savePerson(
    RegisterPersonParams params,
  );
}
