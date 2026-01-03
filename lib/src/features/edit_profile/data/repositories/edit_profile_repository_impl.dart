import 'package:either_dart/either.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/edit_profile/data/datasources/edit_profile_data_source.dart';
import 'package:motogo_frontend/src/features/edit_profile/data/models/edit_profile_model.dart';
import 'package:motogo_frontend/src/features/edit_profile/domain/entities/edit_profile_entity.dart';
import 'package:motogo_frontend/src/features/edit_profile/domain/repositories/edit_profile_repository.dart';

class EditProfileRepositoryImpl implements EditProfileRepository {
  final EditProfileRemoteDataSource dataSource;

  EditProfileRepositoryImpl(this.dataSource);

  @override
  Future<Either<ErrorModel, PersonModel>> getPerson() async {
    try {
      final secureStorage = FlutterSecureStorage();
      final userId = await secureStorage.read(key: 'user_id');
      final token = await secureStorage.read(key: 'access_token');

      if (userId == null || token == null) {
        return Left(
          ErrorModel(
            message:
                'No se encontraron credenciales de usuario. Por favor, inicia sesión nuevamente.',
          ),
        );
      }

      final result = await dataSource.fetchPerson(userId: userId, token: token);

      return result;
    } catch (e) {
      return Left(ErrorModel(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<ErrorModel, void>> updatePerson(PersonEntity person) async {
    try {
      final secureStorage = FlutterSecureStorage();
      final token = await secureStorage.read(key: 'access_token');

      if (token == null) {
        return Left(
          ErrorModel(
            message:
                'No se encontró token de autenticación. Por favor, inicia sesión nuevamente.',
          ),
        );
      }

      final result = await dataSource.patchPerson(
        PersonModel(
          id: person.id,
          identityNumber: person.identityNumber,
          firstName: person.firstName,
          lastName: person.lastName,
          secondLastName: person.secondLastName,
          email: person.email,
          phoneNumber: person.phoneNumber,
          role: person.role,
        ),
        token,
      );

      return result;
    } catch (e) {
      return Left(ErrorModel(message: 'Error inesperado: $e'));
    }
  }
}
