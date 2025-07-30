import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/edit_profile/domain/repositories/edit_profile_repository.dart';
import 'package:motogo_frontend/src/features/edit_profile/domain/entities/edit_profile_entity.dart';

class GetPersonUsecase {
  const GetPersonUsecase(this.repo);
  final EditProfileRepository repo;
  Future<Either<ErrorModel, PersonEntity>> call() => repo.getPerson();
}