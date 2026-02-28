import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register_person/data/datasources/register_person_data_source.dart';
import 'package:motogo_frontend/src/features/register_person/data/models/person_model.dart';
import 'package:motogo_frontend/src/features/register_person/data/repositories/register_repository_impl.dart';
import 'package:motogo_frontend/src/features/register_person/domain/entities/register_person_params.dart';
import 'package:motogo_frontend/src/features/register_person/exceptions/register_person_exceptions.dart';

import 'register_person_repository_impl_test.mocks.dart';

@GenerateMocks([RegisterPersonDataSource])
void main() {
  late RegisterPersonRepositoryImp repository;
  late MockRegisterPersonDataSource mockDataSource;

  const testParams = RegisterPersonParams(
    identityNumber: '1234567890',
    firstName: 'Juan',
    lastName: 'Pérez',
    email: 'juan@test.com',
    phoneNumber: '3001234567',
    password: 'Password123!',
    role: 'USER',
  );

  final testPersonModel = PersonModel(
    id: 'person-1',
    identityNumber: '1234567890',
    firstName: 'Juan',
    lastName: 'Pérez',
    email: 'juan@test.com',
    phoneNumber: '3001234567',
    emailVerified: false,
    phoneNumberVerified: false,
    role: 'USER',
  );

  setUpAll(() {
    provideDummy<Either<ErrorModel, PersonModel>>(Right(testPersonModel));
  });

  setUp(() {
    mockDataSource = MockRegisterPersonDataSource();
    repository = RegisterPersonRepositoryImp(mockDataSource);
  });

  group('RegisterPersonRepositoryImp', () {
    group('savePerson', () {
      test('should return PersonEntity on success', () async {
        when(
          mockDataSource.registerPerson(testParams),
        ).thenAnswer((_) async => Right(testPersonModel));

        final result = await repository.savePerson(testParams);

        expect(result.isRight, isTrue);
        expect(result.right.firstName, 'Juan');
        expect(result.right.email, 'juan@test.com');
        verify(mockDataSource.registerPerson(testParams)).called(1);
      });

      test('should return ErrorModel when datasource returns Left', () async {
        final error = ErrorModel(message: 'Error del servidor');
        when(
          mockDataSource.registerPerson(testParams),
        ).thenAnswer((_) async => Left(error));

        final result = await repository.savePerson(testParams);

        expect(result.isLeft, isTrue);
        expect(result.left.message, 'Error del servidor');
      });

      test('should handle EmailAlreadyExistsException', () async {
        when(
          mockDataSource.registerPerson(testParams),
        ).thenThrow(const EmailAlreadyExistsException());

        final result = await repository.savePerson(testParams);

        expect(result.isLeft, isTrue);
        expect(result.left.message, 'El email ya está registrado');
      });

      test('should handle IdentityNumberExistsException', () async {
        when(
          mockDataSource.registerPerson(testParams),
        ).thenThrow(const IdentityNumberExistsException());

        final result = await repository.savePerson(testParams);

        expect(result.isLeft, isTrue);
        expect(
          result.left.message,
          'El número de documento ya está registrado',
        );
      });

      test('should handle RegisterValidationException', () async {
        when(
          mockDataSource.registerPerson(testParams),
        ).thenThrow(const RegisterValidationException('Campo inválido'));

        final result = await repository.savePerson(testParams);

        expect(result.isLeft, isTrue);
        expect(result.left.message, 'Campo inválido');
      });

      test('should handle SocketException', () async {
        when(
          mockDataSource.registerPerson(testParams),
        ).thenThrow(const SocketException('No connection'));

        final result = await repository.savePerson(testParams);

        expect(result.isLeft, isTrue);
        expect(result.left.message, 'Sin conexión a internet');
      });

      test('should handle FormatException', () async {
        when(
          mockDataSource.registerPerson(testParams),
        ).thenThrow(const FormatException('Bad format'));

        final result = await repository.savePerson(testParams);

        expect(result.isLeft, isTrue);
        expect(result.left.message, 'Formato de datos inválido');
      });

      test('should handle HttpException', () async {
        when(
          mockDataSource.registerPerson(testParams),
        ).thenThrow(const HttpException('Server error'));

        final result = await repository.savePerson(testParams);

        expect(result.isLeft, isTrue);
        expect(result.left.message, 'Error de red: Server error');
      });

      test('should handle generic exceptions', () async {
        when(
          mockDataSource.registerPerson(testParams),
        ).thenThrow(Exception('Unknown error'));

        final result = await repository.savePerson(testParams);

        expect(result.isLeft, isTrue);
        expect(result.left.message, contains('Error del servidor'));
      });
    });
  });
}
