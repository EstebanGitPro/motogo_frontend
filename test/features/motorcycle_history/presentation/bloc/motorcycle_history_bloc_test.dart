import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/entities/completed_service_entity.dart';
import 'package:motogo_frontend/src/features/motorcycle_history/domain/usecases/get_motorcycle_history_usecase.dart';
import 'package:motogo_frontend/src/features/motorcycle_history/presentation/bloc/motorcycle_history_bloc.dart';

import 'motorcycle_history_bloc_test.mocks.dart';

@GenerateMocks([GetMotorcycleHistoryUseCase])
void main() {
  late MockGetMotorcycleHistoryUseCase mockUseCase;

  final testServices = <CompletedServiceEntity>[
    CompletedServiceEntity(
      id: 'svc-1',
      motorcycleId: 'moto-1',
      branchId: 'branch-1',
      requestDate: DateTime(2026, 1, 15),
      status: 'FINALIZADO',
    ),
    CompletedServiceEntity(
      id: 'svc-2',
      motorcycleId: 'moto-1',
      branchId: 'branch-2',
      requestDate: DateTime(2026, 2, 20),
      status: 'EN_PROCESO',
    ),
  ];

  setUpAll(() {
    provideDummy<Either<ErrorModel, List<CompletedServiceEntity>>>(
      const Right(<CompletedServiceEntity>[]),
    );
  });

  setUp(() {
    mockUseCase = MockGetMotorcycleHistoryUseCase();
  });

  group('MotorcycleHistoryBloc', () {
    test('initial state is MotorcycleHistoryInitial', () {
      final bloc = MotorcycleHistoryBloc(
        getMotorcycleHistoryUseCase: mockUseCase,
      );
      expect(bloc.state, isA<MotorcycleHistoryInitial>());
    });

    blocTest<MotorcycleHistoryBloc, MotorcycleHistoryState>(
      'emits [Loading, Loaded] with service history on success',
      setUp: () {
        when(
          mockUseCase.call('moto-1'),
        ).thenAnswer((_) async => Right(testServices));
      },
      build: () =>
          MotorcycleHistoryBloc(getMotorcycleHistoryUseCase: mockUseCase),
      act: (bloc) => bloc.add(const LoadMotorcycleHistory('moto-1')),
      expect: () => [
        isA<MotorcycleHistoryLoading>(),
        isA<MotorcycleHistoryLoaded>()
            .having((s) => s.services.length, 'services', 2)
            .having((s) => s.isEmpty, 'isEmpty', false),
      ],
    );

    blocTest<MotorcycleHistoryBloc, MotorcycleHistoryState>(
      'emits [Loading, Loaded] with empty services',
      setUp: () {
        when(
          mockUseCase.call('moto-2'),
        ).thenAnswer((_) async => const Right(<CompletedServiceEntity>[]));
      },
      build: () =>
          MotorcycleHistoryBloc(getMotorcycleHistoryUseCase: mockUseCase),
      act: (bloc) => bloc.add(const LoadMotorcycleHistory('moto-2')),
      expect: () => [
        isA<MotorcycleHistoryLoading>(),
        isA<MotorcycleHistoryLoaded>()
            .having((s) => s.services, 'services', isEmpty)
            .having((s) => s.isEmpty, 'isEmpty', true),
      ],
    );

    blocTest<MotorcycleHistoryBloc, MotorcycleHistoryState>(
      'emits [Loading, Error] on failure',
      setUp: () {
        when(
          mockUseCase.call('moto-1'),
        ).thenAnswer((_) async => Left(ErrorModel(message: 'Error de red')));
      },
      build: () =>
          MotorcycleHistoryBloc(getMotorcycleHistoryUseCase: mockUseCase),
      act: (bloc) => bloc.add(const LoadMotorcycleHistory('moto-1')),
      expect: () => [
        isA<MotorcycleHistoryLoading>(),
        isA<MotorcycleHistoryError>().having(
          (s) => s.message,
          'message',
          'Error de red',
        ),
      ],
    );
  });
}
