import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register_person/domain/entities/register_person_entity.dart';
import 'package:motogo_frontend/src/features/register_person/domain/usecases/register_person_usecase.dart';
import 'package:motogo_frontend/src/features/register_person/presentation/bloc/register_person_bloc.dart';

import 'register_person_full_bloc_test.mocks.dart';

@GenerateMocks([RegisterPersonUseCase])
void main() {
  late MockRegisterPersonUseCase mockRegister;

  final testPerson = PersonEntity(
    id: 'p-1',
    identityNumber: '123456',
    firstName: 'Juan',
    lastName: 'Pérez',
    email: 'juan@test.com',
    phoneNumber: '3001234567',
    emailVerified: false,
    phoneNumberVerified: false,
    role: 'CUSTOMER',
  );

  setUpAll(() {
    provideDummy<Either<ErrorModel, PersonEntity>>(Right(testPerson));
  });

  setUp(() {
    mockRegister = MockRegisterPersonUseCase();
  });

  RegisterPersonBloc buildBloc() =>
      RegisterPersonBloc(registerUseCase: mockRegister);

  group('RegisterPersonBloc', () {
    test('initial state is RegisterPersonInitial', () {
      expect(buildBloc().state, isA<RegisterPersonInitial>());
    });

    blocTest<RegisterPersonBloc, RegisterPersonState>(
      'emits [Loading, Success] on successful registration',
      setUp: () {
        when(mockRegister.call(any)).thenAnswer((_) async => Right(testPerson));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        RegisterPersonSubmitted(
          identityNumber: '123456',
          firstName: 'Juan',
          lastName: 'Pérez',
          email: 'juan@test.com',
          phoneNumber: '3001234567',
          emailVerified: true,
          phoneNumberVerified: false,
          password: 'Pass123!',
          role: 'CUSTOMER',
        ),
      ),
      expect: () => [
        isA<RegisterPersonLoading>(),
        isA<RegisterPersonSuccess>().having(
          (s) => s.result.firstName,
          'firstName',
          'Juan',
        ),
      ],
    );

    blocTest<RegisterPersonBloc, RegisterPersonState>(
      'emits [Loading, Failure] on error',
      setUp: () {
        when(
          mockRegister.call(any),
        ).thenAnswer((_) async => Left(ErrorModel(message: 'Email ya existe')));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        RegisterPersonSubmitted(
          identityNumber: '123456',
          firstName: 'Juan',
          lastName: 'Pérez',
          email: 'juan@test.com',
          phoneNumber: '3001234567',
          emailVerified: true,
          phoneNumberVerified: false,
          password: 'Pass123!',
          role: 'CUSTOMER',
        ),
      ),
      expect: () => [
        isA<RegisterPersonLoading>(),
        isA<RegisterPersonFailure>(),
      ],
    );
  });
}
