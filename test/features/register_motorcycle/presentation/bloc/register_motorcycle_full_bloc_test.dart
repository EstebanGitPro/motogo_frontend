import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/usecases/register_motorcycle_usecase.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/presentation/bloc/register_motorcycle_bloc.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/presentation/bloc/register_motorcycle_event.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/presentation/bloc/register_motorcycle_state.dart';

import 'register_motorcycle_full_bloc_test.mocks.dart';

@GenerateMocks([RegisterMotorcycleUseCase])
void main() {
  late MockRegisterMotorcycleUseCase mockRegister;

  setUpAll(() {
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockRegister = MockRegisterMotorcycleUseCase();
  });

  RegisterMotorcycleBloc buildBloc() =>
      RegisterMotorcycleBloc(registerMotorcycleUseCase: mockRegister);

  group('RegisterMotorcycleBloc', () {
    test('initial state is RegisterMotorcycleInitial', () {
      expect(buildBloc().state, isA<RegisterMotorcycleInitial>());
    });

    blocTest<RegisterMotorcycleBloc, RegisterMotorcycleState>(
      'emits [Loading, Success] on successful registration',
      setUp: () {
        when(
          mockRegister.call(
            licensePlate: 'ABC12D',
            referenceId: 'ref-1',
            year: 2023,
            currentMileage: 5000,
            ownerNotes: 'Mi moto',
            profileImageUrl: null,
          ),
        ).thenAnswer((_) async => const Right('Moto registrada'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        SubmitMotorcycleRegistration(
          licensePlate: 'ABC12D',
          referenceId: 'ref-1',
          year: 2023,
          currentMileage: 5000,
          ownerNotes: 'Mi moto',
        ),
      ),
      expect: () => [
        isA<RegisterMotorcycleLoading>(),
        isA<RegisterMotorcycleSuccess>(),
      ],
    );

    blocTest<RegisterMotorcycleBloc, RegisterMotorcycleState>(
      'emits [Loading, Failure] on error',
      setUp: () {
        when(
          mockRegister.call(
            licensePlate: 'ABC12D',
            referenceId: null,
            year: null,
            currentMileage: null,
            ownerNotes: null,
            profileImageUrl: null,
          ),
        ).thenAnswer((_) async => Left(ErrorModel(message: 'Placa duplicada')));
      },
      build: buildBloc,
      act: (bloc) =>
          bloc.add(SubmitMotorcycleRegistration(licensePlate: 'ABC12D')),
      expect: () => [
        isA<RegisterMotorcycleLoading>(),
        isA<RegisterMotorcycleFailure>(),
      ],
    );

    blocTest<RegisterMotorcycleBloc, RegisterMotorcycleState>(
      'emits [Initial] on reset',
      build: buildBloc,
      act: (bloc) => bloc.add(ResetMotorcycleForm()),
      expect: () => [isA<RegisterMotorcycleInitial>()],
    );
  });
}
