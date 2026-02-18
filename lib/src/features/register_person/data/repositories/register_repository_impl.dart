import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register_person/data/datasources/register_person_data_source.dart';
import 'package:motogo_frontend/src/features/register_person/domain/entities/register_person_entity.dart';
import 'package:motogo_frontend/src/features/register_person/domain/entities/register_person_params.dart';
import 'package:motogo_frontend/src/features/register_person/domain/repositories/register_person_repository.dart';
import 'package:motogo_frontend/src/features/register_person/exceptions/register_person_exceptions.dart';

class RegisterPersonRepositoryImp implements RegisterPersonRepository {
  final RegisterPersonDataSource _registerPersonDataSource;

  RegisterPersonRepositoryImp(this._registerPersonDataSource);

  @override
  Future<Either<ErrorModel, PersonEntity>> savePerson(
    RegisterPersonParams params,
  ) async {
    try {
      final result = await _registerPersonDataSource.registerPerson(params);

      return result.fold(
        (error) => Left(error),
        (personModel) => Right(personModel),
      );
    } on EmailAlreadyExistsException {
      return Left(
        ErrorModel(message: 'El email ya está registrado', isError: true),
      );
    } on IdentityNumberExistsException {
      return Left(
        ErrorModel(
          message: 'El número de documento ya está registrado',
          isError: true,
        ),
      );
    } on RegisterValidationException catch (e) {
      return Left(ErrorModel(message: e.message, isError: true));
    } on SocketException {
      return Left(
        ErrorModel(message: 'Sin conexión a internet', isError: true),
      );
    } on FormatException {
      return Left(
        ErrorModel(message: 'Formato de datos inválido', isError: true),
      );
    } on HttpException catch (e) {
      return Left(
        ErrorModel(message: 'Error de red: ${e.message}', isError: true),
      );
    } catch (e) {
      return Left(
        ErrorModel(
          message: 'Error del servidor: ${e.toString()}',
          isError: true,
        ),
      );
    }
  }
}
