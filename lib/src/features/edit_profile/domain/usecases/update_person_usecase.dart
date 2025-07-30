import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/edit_profile/domain/repositories/edit_profile_repository.dart';
import 'package:motogo_frontend/src/features/edit_profile/domain/entities/edit_profile_entity.dart';

class UpdatePersonUsecase {
  const UpdatePersonUsecase(this._repo);
  final EditProfileRepository _repo;

  Future<Either<ErrorModel, void>> call(PersonEntity person) =>
      _repo.updatePerson(person);
}