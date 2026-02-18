import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register_person/domain/entities/register_person_entity.dart';
import 'package:motogo_frontend/src/features/register_person/domain/entities/register_person_params.dart';
import 'package:motogo_frontend/src/features/register_person/domain/repositories/register_person_repository.dart';
import 'package:motogo_frontend/src/features/register_person/domain/usecases/register_person_usecase.dart';

import 'register_person_usecase_test.mocks.dart';

@GenerateMocks([RegisterPersonRepository])
void main() {
  late RegisterPersonUseCase useCase;
  late MockRegisterPersonRepository mockRepository;

  final testParams = RegisterPersonParams(
    identityNumber: '1234567890',
    firstName: 'Juan',
    lastName: 'Pérez',
    email: 'juan@test.com',
    phoneNumber: '3001234567',
    password: 'Password123!',
    role: 'USER',
  );

  final testPerson = PersonEntity(
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
    provideDummy<Either<ErrorModel, PersonEntity>>(Right(testPerson));
  });

  setUp(() {
    mockRepository = MockRegisterPersonRepository();
    useCase = RegisterPersonUseCase(mockRepository);
  });

  group('RegisterPersonUseCase', () {
    test('should return PersonEntity on success', () async {
      when(
        mockRepository.savePerson(testParams),
      ).thenAnswer((_) async => Right(testPerson));

      final result = await useCase.call(testParams);

      expect(result.isRight, isTrue);
      expect(result.right.firstName, 'Juan');
      verify(mockRepository.savePerson(testParams)).called(1);
    });

    test('should return ErrorModel on failure', () async {
      final error = ErrorModel(
        message: 'Email en uso',
        errorCode: 'EMAIL_TAKEN',
      );
      when(
        mockRepository.savePerson(testParams),
      ).thenAnswer((_) async => Left(error));

      final result = await useCase.call(testParams);

      expect(result.isLeft, isTrue);
      expect(result.left.message, 'Email en uso');
    });
  });
}
