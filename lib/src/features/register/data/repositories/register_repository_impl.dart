import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register/data/datasources/register_data_source.dart';
import 'package:motogo_frontend/src/features/register/domain/entities/person_entity.dart';
import 'package:motogo_frontend/src/features/register/domain/repositories/register_repository.dart';
import 'package:motogo_frontend/src/features/register/exceptions/register_exceptions.dart';

class RegisterRepositoryImp implements RegisterRepository {
  final RegisterDataSource _registerDataSource;

  RegisterRepositoryImp(this._registerDataSource);

  @override
  Future<Either<ErrorModel, PersonEntity>> savePerson(
    String identityNumber,
    String firstName,
    String lastName,
    String? secondLastName,
    String email,
    String phoneNumber,
    String password,
    String role,
  ) async {
    try {
      final result = await _registerDataSource.registerPerson(
        identityNumber,
        firstName,
        lastName,
        secondLastName,
        email,
        phoneNumber,
        password,
        role,
      );
      
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