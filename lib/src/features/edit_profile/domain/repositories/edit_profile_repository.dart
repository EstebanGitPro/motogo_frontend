
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/edit_profile/data/models/edit_profile_model.dart';
import 'package:motogo_frontend/src/features/edit_profile/domain/entities/edit_profile_entity.dart';

abstract class EditProfileRepository {
  Future<Either<ErrorModel, PersonModel>> getPerson();
  Future<Either<ErrorModel, void>> updatePerson(PersonEntity person);
}
