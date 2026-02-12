import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/diagnostic/domain/entity/diagnostic_entity.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/entities/motorcycle_detail_entity.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/usecases/search_motorcycle_by_plate_usecase.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/usecases/set_solution_usecase.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/presentation/bloc/search_motorcycle_bloc.dart';

import 'search_motorcycle_bloc_test.mocks.dart';

@GenerateMocks([SearchMotorcycleByPlateUseCase, SetSolutionUseCase])
void main() {
  late SearchMotorcycleBloc bloc;
  late MockSearchMotorcycleByPlateUseCase mockSearchUseCase;
  late MockSetSolutionUseCase mockSetSolutionUseCase;

  setUpAll(() {
    provideDummy<Either<ErrorModel, MotorcycleDetailEntity>>(
      const Right(
        MotorcycleDetailEntity(
          id: '',
          licensePlate: '',
          year: 0,
          currentMileage: 0,
          reference: MotorcycleReferenceInfoEntity(
            brandName: '',
            model: '',
            category: '',
            engineDisplacementCc: 0,
          ),
        ),
      ),
    );
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockSearchUseCase = MockSearchMotorcycleByPlateUseCase();
    mockSetSolutionUseCase = MockSetSolutionUseCase();
    bloc = SearchMotorcycleBloc(
      searchUseCase: mockSearchUseCase,
      setSolutionUseCase: mockSetSolutionUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  const testReference = MotorcycleReferenceInfoEntity(
    brandName: 'Yamaha',
    model: 'MT-07',
    category: 'Naked',
    engineDisplacementCc: 689,
  );

  final testEntity = MotorcycleDetailEntity(
    id: 'moto-123',
    licensePlate: 'ABC12D',
    year: 2023,
    currentMileage: 5000,
    reference: testReference,
    diagnostics: [
      DiagnosticEntity(
        id: 'diag-1',
        motorcycleId: 'moto-123',
        problemDescription: 'Ruido extraño',
        date: DateTime(2024, 1, 15),
      ),
    ],
  );

  group('SearchMotorcycleBloc', () {
    test('initial state should be SearchMotorcycleInitial', () {
      expect(bloc.state, isA<SearchMotorcycleInitial>());
    });

    group('SearchByPlate', () {
      blocTest<SearchMotorcycleBloc, SearchMotorcycleState>(
        'emits [Loading, Loaded] when search succeeds',
        build: () {
          when(
            mockSearchUseCase.call(any),
          ).thenAnswer((_) async => Right(testEntity));
          return bloc;
        },
        act: (bloc) => bloc.add(const SearchByPlate('abc12d')),
        expect: () => [
          isA<SearchMotorcycleLoading>(),
          isA<SearchMotorcycleLoaded>(),
        ],
        verify: (_) {
          // Plate should be uppercased and trimmed
          verify(mockSearchUseCase.call('ABC12D')).called(1);
        },
      );

      blocTest<SearchMotorcycleBloc, SearchMotorcycleState>(
        'emits [Loading, Error] when search fails',
        build: () {
          when(mockSearchUseCase.call(any)).thenAnswer(
            (_) async => Left(
              ErrorModel(
                errorCode: 'NOT_FOUND',
                message: 'No se encontró la motocicleta',
              ),
            ),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const SearchByPlate('XYZ99Z')),
        expect: () => [
          isA<SearchMotorcycleLoading>(),
          isA<SearchMotorcycleError>(),
        ],
      );

      blocTest<SearchMotorcycleBloc, SearchMotorcycleState>(
        'error state contains the error message',
        build: () {
          when(mockSearchUseCase.call(any)).thenAnswer(
            (_) async => Left(
              ErrorModel(errorCode: 'NOT_FOUND', message: 'Moto no encontrada'),
            ),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const SearchByPlate('ZZZ00Z')),
        expect: () => [
          isA<SearchMotorcycleLoading>(),
          predicate<SearchMotorcycleState>(
            (state) =>
                state is SearchMotorcycleError &&
                state.message == 'Moto no encontrada',
          ),
        ],
      );

      blocTest<SearchMotorcycleBloc, SearchMotorcycleState>(
        'uppercases and trims the plate input',
        build: () {
          when(
            mockSearchUseCase.call(any),
          ).thenAnswer((_) async => Right(testEntity));
          return bloc;
        },
        act: (bloc) => bloc.add(const SearchByPlate('  abc12d  ')),
        verify: (_) {
          verify(mockSearchUseCase.call('ABC12D')).called(1);
        },
      );
    });

    group('ClearSearch', () {
      blocTest<SearchMotorcycleBloc, SearchMotorcycleState>(
        'emits [Initial] when ClearSearch is added',
        build: () => bloc,
        act: (bloc) => bloc.add(const ClearSearch()),
        expect: () => [isA<SearchMotorcycleInitial>()],
      );
    });

    group('SetDiagnosticSolution', () {
      blocTest<SearchMotorcycleBloc, SearchMotorcycleState>(
        'emits updated Loaded state with solution when succeeds',
        build: () {
          when(
            mockSearchUseCase.call(any),
          ).thenAnswer((_) async => Right(testEntity));
          when(
            mockSetSolutionUseCase.call(
              diagnosticId: anyNamed('diagnosticId'),
              solution: anyNamed('solution'),
            ),
          ).thenAnswer((_) async => const Right('Solución guardada'));
          return bloc;
        },
        act: (bloc) async {
          bloc.add(const SearchByPlate('ABC12D'));
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(
            const SetDiagnosticSolution(
              diagnosticId: 'diag-1',
              solution: 'Cambiar filtro',
            ),
          );
        },
        wait: const Duration(milliseconds: 200),
        expect: () => [
          isA<SearchMotorcycleLoading>(),
          isA<SearchMotorcycleLoaded>(),
          predicate<SearchMotorcycleState>(
            (state) =>
                state is SearchMotorcycleLoaded &&
                state.solutionMessage == 'Solución guardada' &&
                state.motorcycle.diagnostics.any(
                  (d) =>
                      d.id == 'diag-1' &&
                      d.possibleSolution == 'Cambiar filtro',
                ),
          ),
        ],
      );

      blocTest<SearchMotorcycleBloc, SearchMotorcycleState>(
        'emits Loaded with solutionError when setSolution fails',
        build: () {
          when(
            mockSearchUseCase.call(any),
          ).thenAnswer((_) async => Right(testEntity));
          when(
            mockSetSolutionUseCase.call(
              diagnosticId: anyNamed('diagnosticId'),
              solution: anyNamed('solution'),
            ),
          ).thenAnswer(
            (_) async =>
                Left(ErrorModel(errorCode: 'ERR', message: 'Error al guardar')),
          );
          return bloc;
        },
        act: (bloc) async {
          bloc.add(const SearchByPlate('ABC12D'));
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(
            const SetDiagnosticSolution(
              diagnosticId: 'diag-1',
              solution: 'Algo',
            ),
          );
        },
        wait: const Duration(milliseconds: 200),
        expect: () => [
          isA<SearchMotorcycleLoading>(),
          isA<SearchMotorcycleLoaded>(),
          predicate<SearchMotorcycleState>(
            (state) =>
                state is SearchMotorcycleLoaded &&
                state.solutionError == 'Error al guardar',
          ),
        ],
      );

      blocTest<SearchMotorcycleBloc, SearchMotorcycleState>(
        'does nothing when state is not Loaded',
        build: () => bloc,
        act: (bloc) => bloc.add(
          const SetDiagnosticSolution(diagnosticId: 'diag-1', solution: 'Algo'),
        ),
        expect: () => [],
      );
    });
  });

  group('SearchMotorcycleEvent', () {
    test('SearchByPlate props should contain plate', () {
      const event = SearchByPlate('ABC12D');
      expect(event.props, ['ABC12D']);
    });

    test('ClearSearch props should be empty', () {
      const event = ClearSearch();
      expect(event.props, isEmpty);
    });

    test('SetDiagnosticSolution props should contain id and solution', () {
      const event = SetDiagnosticSolution(
        diagnosticId: 'diag-1',
        solution: 'Fix it',
      );
      expect(event.props, ['diag-1', 'Fix it']);
    });
  });

  group('SearchMotorcycleState', () {
    test('SearchMotorcycleInitial props should be empty', () {
      const state = SearchMotorcycleInitial();
      expect(state.props, isEmpty);
    });

    test('SearchMotorcycleLoading props should be empty', () {
      const state = SearchMotorcycleLoading();
      expect(state.props, isEmpty);
    });

    test('SearchMotorcycleError props should contain message', () {
      const state = SearchMotorcycleError('Something went wrong');
      expect(state.props, ['Something went wrong']);
    });

    test('SearchMotorcycleLoaded copyWith should update fields', () {
      final loaded = SearchMotorcycleLoaded(testEntity);
      final updated = loaded.copyWith(solutionMessage: 'Saved');

      expect(updated.solutionMessage, 'Saved');
      expect(updated.motorcycle, testEntity);
    });

    test('SearchMotorcycleLoaded copyWith with motorcycle', () {
      final loaded = SearchMotorcycleLoaded(testEntity);
      const newEntity = MotorcycleDetailEntity(
        id: 'moto-999',
        licensePlate: 'ZZZ00Z',
        year: 2025,
        currentMileage: 0,
        reference: testReference,
      );

      final updated = loaded.copyWith(motorcycle: newEntity);

      expect(updated.motorcycle.id, 'moto-999');
    });

    test('SearchMotorcycleLoaded props should include all fields', () {
      final loaded = SearchMotorcycleLoaded(
        testEntity,
        solutionMessage: 'msg',
        solutionError: 'err',
      );

      expect(loaded.props.length, 3);
      expect(loaded.props, contains(testEntity));
      expect(loaded.props, contains('msg'));
      expect(loaded.props, contains('err'));
    });
  });
}
