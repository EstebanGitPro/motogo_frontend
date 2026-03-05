import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register_franchise/domain/entities/franchise_entity.dart';
import 'package:motogo_frontend/src/features/register_franchise/domain/usecases/register_franchise_usecase.dart';
import 'package:motogo_frontend/src/features/register_franchise/presentation/bloc/register_franchise_bloc.dart';
import 'package:motogo_frontend/src/features/register_franchise/presentation/bloc/register_franchise_event.dart';
import 'package:motogo_frontend/src/features/register_franchise/presentation/bloc/register_franchise_state.dart';

import 'register_franchise_bloc_test.mocks.dart';

@GenerateMocks([RegisterFranchiseUseCase])
void main() {
  late MockRegisterFranchiseUseCase mockUseCase;
  late RegisterFranchiseBloc bloc;

  const tFranchise = FranchiseEntity(
    name: 'MotoRed',
    description: 'Red de talleres',
    branchIds: ['branch-1'],
  );

  const tResult = FranchiseEntity(
    id: 'franchise-abc',
    name: 'MotoRed',
    description: 'Red de talleres',
    branchIds: ['branch-1'],
  );

  const tMessage = 'Franquicia creada exitosamente';

  setUpAll(() {
    provideDummy<Either<ErrorModel, (FranchiseEntity, String)>>(
      const Right((tResult, tMessage)),
    );
  });

  setUp(() {
    mockUseCase = MockRegisterFranchiseUseCase();
    bloc = RegisterFranchiseBloc(registerFranchiseUseCase: mockUseCase);
  });

  tearDown(() => bloc.close());

  group('RegisterFranchiseBloc', () {
    test('initial state is RegisterFranchiseInitial', () {
      expect(bloc.state, isA<RegisterFranchiseInitial>());
    });

    blocTest<RegisterFranchiseBloc, RegisterFranchiseState>(
      'emits [Loading, Success] with backend message on successful registration',
      build: () {
        when(
          mockUseCase.call(any),
        ).thenAnswer((_) async => const Right((tResult, tMessage)));
        return bloc;
      },
      act: (bloc) => bloc.add(const SubmitFranchise(tFranchise)),
      expect: () => [
        isA<RegisterFranchiseLoading>(),
        isA<RegisterFranchiseSuccess>()
            .having((s) => s.franchise.id, 'franchise.id', 'franchise-abc')
            .having((s) => s.message, 'message', tMessage),
      ],
      verify: (_) {
        verify(mockUseCase.call(tFranchise)).called(1);
      },
    );

    blocTest<RegisterFranchiseBloc, RegisterFranchiseState>(
      'emits [Loading, Error] with backend message on failure',
      build: () {
        when(mockUseCase.call(any)).thenAnswer(
          (_) async => Left(
            ErrorModel(message: 'Error del servidor', errorCode: 'ERR_500'),
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const SubmitFranchise(tFranchise)),
      expect: () => [
        isA<RegisterFranchiseLoading>(),
        isA<RegisterFranchiseError>()
            .having((s) => s.message, 'message', 'Error del servidor')
            .having((s) => s.code, 'code', 'ERR_500'),
      ],
    );

    blocTest<RegisterFranchiseBloc, RegisterFranchiseState>(
      'emits [Loading, Error] with UNKNOWN code when errorCode is null',
      build: () {
        when(
          mockUseCase.call(any),
        ).thenAnswer((_) async => Left(ErrorModel(message: 'Error genérico')));
        return bloc;
      },
      act: (bloc) => bloc.add(const SubmitFranchise(tFranchise)),
      expect: () => [
        isA<RegisterFranchiseLoading>(),
        isA<RegisterFranchiseError>().having((s) => s.code, 'code', 'UNKNOWN'),
      ],
    );

    blocTest<RegisterFranchiseBloc, RegisterFranchiseState>(
      'emits [Initial] on ResetFranchiseForm',
      build: () => bloc,
      act: (bloc) => bloc.add(const ResetFranchiseForm()),
      expect: () => [isA<RegisterFranchiseInitial>()],
    );
  });
}
