import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/delete_motorcycle/domain/usecases/delete_motorcycle_usecase.dart';
import 'package:motogo_frontend/src/features/my_motorcycles/domain/usecases/get_my_motorcycles_usecase.dart';
import 'package:motogo_frontend/src/features/my_motorcycles/presentation/bloc/my_motorcycles_bloc.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/entities/motorcycle_entity.dart';

import 'my_motorcycles_bloc_test.mocks.dart';

@GenerateMocks([GetMyMotorcyclesUseCase, DeleteMotorcycleUseCase])
void main() {
  late MockGetMyMotorcyclesUseCase mockGetUseCase;
  late MockDeleteMotorcycleUseCase mockDeleteUseCase;

  final testMotorcycles = <MotorcycleEntity>[
    const MotorcycleEntity(
      id: 'moto-1',
      licensePlate: 'ABC123',
      referenceId: 'ref-1',
      year: 2024,
    ),
    const MotorcycleEntity(
      id: 'moto-2',
      licensePlate: 'DEF456',
      referenceId: 'ref-2',
      year: 2023,
    ),
  ];

  setUpAll(() {
    provideDummy<Either<ErrorModel, List<MotorcycleEntity>>>(
      const Right(<MotorcycleEntity>[]),
    );
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockGetUseCase = MockGetMyMotorcyclesUseCase();
    mockDeleteUseCase = MockDeleteMotorcycleUseCase();
  });

  MyMotorcyclesBloc buildBloc() => MyMotorcyclesBloc(
    getMyMotorcyclesUseCase: mockGetUseCase,
    deleteMotorcycleUseCase: mockDeleteUseCase,
  );

  group('MyMotorcyclesBloc', () {
    test('initial state is MyMotorcyclesInitial', () {
      expect(buildBloc().state, isA<MyMotorcyclesInitial>());
    });

    group('LoadMyMotorcycles', () {
      blocTest<MyMotorcyclesBloc, MyMotorcyclesState>(
        'emits [Loading, Loaded] on success',
        setUp: () {
          when(mockGetUseCase.call()).thenAnswer(
            (_) async =>
                Right<ErrorModel, List<MotorcycleEntity>>(testMotorcycles),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const LoadMyMotorcycles()),
        expect: () => [
          isA<MyMotorcyclesLoading>(),
          isA<MyMotorcyclesLoaded>()
              .having((s) => s.motorcycles.length, 'motorcycles', 2)
              .having((s) => s.isEmpty, 'isEmpty', false),
        ],
      );

      blocTest<MyMotorcyclesBloc, MyMotorcyclesState>(
        'emits [Loading, Loaded] with empty list',
        setUp: () {
          when(mockGetUseCase.call()).thenAnswer(
            (_) async => const Right<ErrorModel, List<MotorcycleEntity>>([]),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const LoadMyMotorcycles()),
        expect: () => [
          isA<MyMotorcyclesLoading>(),
          isA<MyMotorcyclesLoaded>()
              .having((s) => s.motorcycles, 'motorcycles', isEmpty)
              .having((s) => s.isEmpty, 'isEmpty', true),
        ],
      );

      blocTest<MyMotorcyclesBloc, MyMotorcyclesState>(
        'emits [Loading, Error] on failure',
        setUp: () {
          when(
            mockGetUseCase.call(),
          ).thenAnswer((_) async => Left(ErrorModel(message: 'Error')));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const LoadMyMotorcycles()),
        expect: () => [
          isA<MyMotorcyclesLoading>(),
          isA<MyMotorcyclesError>().having(
            (s) => s.message,
            'message',
            'Error',
          ),
        ],
      );
    });

    group('DeleteMotorcycle', () {
      blocTest<MyMotorcyclesBloc, MyMotorcyclesState>(
        'emits [Loading, Deleted, Loading, Loaded] on success',
        setUp: () {
          when(
            mockDeleteUseCase.call('moto-1'),
          ).thenAnswer((_) async => const Right('Moto eliminada'));
          when(mockGetUseCase.call()).thenAnswer(
            (_) async => Right<ErrorModel, List<MotorcycleEntity>>([
              testMotorcycles.last,
            ]),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const DeleteMotorcycle('moto-1')),
        expect: () => [
          isA<MyMotorcyclesLoading>(),
          isA<MyMotorcycleDeleted>().having(
            (s) => s.message,
            'message',
            'Moto eliminada',
          ),
          isA<MyMotorcyclesLoading>(),
          isA<MyMotorcyclesLoaded>().having(
            (s) => s.motorcycles.length,
            'motorcycles',
            1,
          ),
        ],
      );

      blocTest<MyMotorcyclesBloc, MyMotorcyclesState>(
        'emits [Loading, DeleteError] on failure',
        setUp: () {
          when(mockDeleteUseCase.call('moto-1')).thenAnswer(
            (_) async => Left(ErrorModel(message: 'Error eliminando')),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const DeleteMotorcycle('moto-1')),
        expect: () => [
          isA<MyMotorcyclesLoading>(),
          isA<MyMotorcycleDeleteError>().having(
            (s) => s.message,
            'message',
            'Error eliminando',
          ),
        ],
      );
    });
  });
}
