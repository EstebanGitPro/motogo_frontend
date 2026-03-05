import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/completed_services/data/model/status_transition_model.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/entities/completed_service_entity.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/usecases/get_service_history_usecase.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/usecases/get_service_transitions_usecase.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/usecases/register_completed_service_usecase.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/usecases/update_service_status_usecase.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/usecases/update_service_details_usecase.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/usecases/delete_completed_service_usecase.dart';
import 'package:motogo_frontend/src/features/diagnostic/domain/entity/diagnostic_entity.dart';
import 'package:motogo_frontend/src/features/my_branches/domain/usecases/get_branches_usecase.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/entities/motorcycle_detail_entity.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/usecases/search_motorcycle_by_plate_usecase.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/usecases/set_solution_usecase.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/presentation/bloc/search_motorcycle_bloc.dart';

import 'search_motorcycle_bloc_test.mocks.dart';

@GenerateMocks([
  SearchMotorcycleByPlateUseCase,
  SetSolutionUseCase,
  RegisterCompletedServiceUseCase,
  GetServiceHistoryUseCase,
  GetBranchesUseCase,
  UpdateServiceStatusUseCase,
  GetServiceTransitionsUseCase,
  DeleteCompletedServiceUseCase,
  UpdateServiceDetailsUseCase,
])
void main() {
  late SearchMotorcycleBloc bloc;
  late MockSearchMotorcycleByPlateUseCase mockSearchUseCase;
  late MockSetSolutionUseCase mockSetSolutionUseCase;
  late MockRegisterCompletedServiceUseCase mockRegisterServiceUseCase;
  late MockGetServiceHistoryUseCase mockGetServiceHistoryUseCase;
  late MockGetBranchesUseCase mockGetBranchesUseCase;
  late MockUpdateServiceStatusUseCase mockUpdateServiceStatusUseCase;
  late MockGetServiceTransitionsUseCase mockGetServiceTransitionsUseCase;
  late MockDeleteCompletedServiceUseCase mockDeleteCompletedServiceUseCase;
  late MockUpdateServiceDetailsUseCase mockUpdateServiceDetailsUseCase;

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
    provideDummy<Either<ErrorModel, List<CompletedServiceEntity>>>(
      const Right([]),
    );
    provideDummy<Either<ErrorModel, List<BranchEntity>>>(const Right([]));
    provideDummy<Either<ErrorModel, List<StatusTransitionModel>>>(
      const Right([]),
    );
  });

  setUp(() {
    mockSearchUseCase = MockSearchMotorcycleByPlateUseCase();
    mockSetSolutionUseCase = MockSetSolutionUseCase();
    mockRegisterServiceUseCase = MockRegisterCompletedServiceUseCase();
    mockGetServiceHistoryUseCase = MockGetServiceHistoryUseCase();
    mockGetBranchesUseCase = MockGetBranchesUseCase();
    mockUpdateServiceStatusUseCase = MockUpdateServiceStatusUseCase();
    mockGetServiceTransitionsUseCase = MockGetServiceTransitionsUseCase();
    mockDeleteCompletedServiceUseCase = MockDeleteCompletedServiceUseCase();
    mockUpdateServiceDetailsUseCase = MockUpdateServiceDetailsUseCase();
    // Default mock: representative has no branches (prevents auto-fetch)
    when(
      mockGetBranchesUseCase.call(),
    ).thenAnswer((_) async => const Right([]));
    bloc = SearchMotorcycleBloc(
      searchUseCase: mockSearchUseCase,
      setSolutionUseCase: mockSetSolutionUseCase,
      registerServiceUseCase: mockRegisterServiceUseCase,
      getServiceHistoryUseCase: mockGetServiceHistoryUseCase,
      getBranchesUseCase: mockGetBranchesUseCase,
      updateServiceStatusUseCase: mockUpdateServiceStatusUseCase,
      getServiceTransitionsUseCase: mockGetServiceTransitionsUseCase,
      deleteCompletedServiceUseCase: mockDeleteCompletedServiceUseCase,
      updateServiceDetailsUseCase: mockUpdateServiceDetailsUseCase,
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

    group('RegisterCompletedService', () {
      blocTest<SearchMotorcycleBloc, SearchMotorcycleState>(
        'emits Loaded with serviceRegistrationMessage on success',
        build: () {
          when(
            mockSearchUseCase.call(any),
          ).thenAnswer((_) async => Right(testEntity));
          when(mockRegisterServiceUseCase.call(any)).thenAnswer(
            (_) async => const Right('Servicio registrado exitosamente'),
          );
          return bloc;
        },
        act: (bloc) async {
          bloc.add(const SearchByPlate('ABC12D'));
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(
            const RegisterCompletedService(
              branchId: 'branch-1',
              motorcycleId: 'moto-123',
              serviceIds: ['svc-1', 'svc-2'],
              quotedPrice: 185000,
              finalPrice: 175000,
              representativeNotes: 'Cambio de aceite',
            ),
          );
        },
        wait: const Duration(milliseconds: 200),
        expect: () => [
          isA<SearchMotorcycleLoading>(),
          isA<SearchMotorcycleLoaded>(),
          // isRegisteringService = true
          predicate<SearchMotorcycleState>(
            (state) =>
                state is SearchMotorcycleLoaded &&
                state.isRegisteringService == true,
          ),
          // Success message
          predicate<SearchMotorcycleState>(
            (state) =>
                state is SearchMotorcycleLoaded &&
                state.isRegisteringService == false &&
                state.serviceRegistrationMessage ==
                    'Servicio registrado exitosamente',
          ),
        ],
      );

      blocTest<SearchMotorcycleBloc, SearchMotorcycleState>(
        'emits Loaded with serviceRegistrationError on failure',
        build: () {
          when(
            mockSearchUseCase.call(any),
          ).thenAnswer((_) async => Right(testEntity));
          when(mockRegisterServiceUseCase.call(any)).thenAnswer(
            (_) async => Left(
              ErrorModel(errorCode: 'ERR', message: 'Error al registrar'),
            ),
          );
          return bloc;
        },
        act: (bloc) async {
          bloc.add(const SearchByPlate('ABC12D'));
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(
            const RegisterCompletedService(
              branchId: 'branch-1',
              motorcycleId: 'moto-123',
              serviceIds: ['svc-1'],
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
                state.isRegisteringService == true,
          ),
          predicate<SearchMotorcycleState>(
            (state) =>
                state is SearchMotorcycleLoaded &&
                state.isRegisteringService == false &&
                state.serviceRegistrationError == 'Error al registrar',
          ),
        ],
      );

      blocTest<SearchMotorcycleBloc, SearchMotorcycleState>(
        'does nothing when state is not Loaded',
        build: () => bloc,
        act: (bloc) => bloc.add(
          const RegisterCompletedService(
            branchId: 'branch-1',
            motorcycleId: 'moto-123',
            serviceIds: ['svc-1'],
          ),
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

    test(
      'FetchServiceHistory props should contain motorcycleId and branchIds',
      () {
        const event = FetchServiceHistory(
          motorcycleId: 'moto-1',
          branchIds: ['b-1', 'b-2'],
        );
        expect(event.props, [
          'moto-1',
          ['b-1', 'b-2'],
        ]);
      },
    );
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

      expect(loaded.props.length, 6);
      expect(loaded.props, contains(testEntity));
      expect(loaded.props, contains('msg'));
      expect(loaded.props, contains('err'));
    });

    test('RegisterCompletedService props should contain all fields', () {
      const event = RegisterCompletedService(
        branchId: 'branch-1',
        motorcycleId: 'moto-1',
        serviceIds: ['svc-1'],
        quotedPrice: 100.0,
        finalPrice: 90.0,
        representativeNotes: 'notes',
      );
      expect(event.props, [
        'branch-1',
        'moto-1',
        ['svc-1'],
        100.0,
        90.0,
        'notes',
      ]);
    });

    test(
      'SearchMotorcycleLoaded copyWith with service registration fields',
      () {
        final loaded = SearchMotorcycleLoaded(testEntity);
        final updated = loaded.copyWith(
          registration: const ServiceRegistrationStatus(
            isRegistering: true,
            message: 'OK',
          ),
        );

        expect(updated.isRegisteringService, true);
        expect(updated.serviceRegistrationMessage, 'OK');
      },
    );

    test('UpdateServiceStatus props should contain all fields', () {
      const event = UpdateServiceStatus(
        serviceId: 'svc-1',
        motorcycleId: 'moto-1',
        newStatus: 'EN_PROCESO',
      );
      expect(event.props, ['svc-1', 'moto-1', 'EN_PROCESO', null]);
    });

    test('UpdateServiceStatus props with finalPrice', () {
      const event = UpdateServiceStatus(
        serviceId: 'svc-1',
        motorcycleId: 'moto-1',
        newStatus: 'FINALIZADO',
        finalPrice: 150000,
      );
      expect(event.props, ['svc-1', 'moto-1', 'FINALIZADO', 150000.0]);
    });

    test('UpdateServiceDetails props should contain all fields', () {
      const event = UpdateServiceDetails(
        serviceId: 'svc-1',
        motorcycleId: 'moto-1',
        quotedPrice: 200000,
        finalPrice: 180000,
        representativeNotes: 'Notas del representante',
      );
      expect(event.props, [
        'svc-1',
        'moto-1',
        200000.0,
        180000.0,
        'Notas del representante',
      ]);
    });

    test('FetchServiceTransitions props should contain serviceId', () {
      const event = FetchServiceTransitions(serviceId: 'svc-1');
      expect(event.props, ['svc-1']);
    });

    test(
      'DeleteCompletedService props should contain serviceId and motorcycleId',
      () {
        const event = DeleteCompletedService(
          serviceId: 'svc-1',
          motorcycleId: 'moto-1',
        );
        expect(event.props, ['svc-1', 'moto-1']);
      },
    );

    test('SearchMotorcycleLoaded copyWith with status update fields', () {
      final loaded = SearchMotorcycleLoaded(testEntity);
      final updated = loaded.copyWith(
        action: const ServiceActionStatus(
          statusUpdate: AsyncActionState(
            isLoading: true,
            message: 'Updated',
            error: 'Failed',
          ),
        ),
      );

      expect(updated.isUpdatingStatus, true);
      expect(updated.statusUpdateMessage, 'Updated');
      expect(updated.statusUpdateError, 'Failed');
    });

    test('SearchMotorcycleLoaded copyWith with serviceTransitions', () {
      final loaded = SearchMotorcycleLoaded(testEntity);
      final updated = loaded.copyWith(
        history: const ServiceHistoryStatus(transitions: []),
      );

      expect(updated.serviceTransitions, isEmpty);
    });

    test('SearchMotorcycleLoaded copyWith with delete service fields', () {
      final loaded = SearchMotorcycleLoaded(testEntity);
      final updated = loaded.copyWith(
        action: const ServiceActionStatus(
          deleteAction: AsyncActionState(
            isLoading: true,
            message: 'Deleted',
            error: 'Error deleting',
          ),
        ),
      );

      expect(updated.isDeletingService, true);
      expect(updated.deleteServiceMessage, 'Deleted');
      expect(updated.deleteServiceError, 'Error deleting');
    });
  });

  // ─── UpdateServiceStatus Handler ─────────────────────────────────

  group('UpdateServiceStatus Handler', () {
    blocTest<SearchMotorcycleBloc, SearchMotorcycleState>(
      'emits updated state on success',
      build: () {
        when(
          mockUpdateServiceStatusUseCase.call(
            any,
            any,
            finalPrice: anyNamed('finalPrice'),
          ),
        ).thenAnswer(
          (_) async => const Right('Estado actualizado exitosamente'),
        );
        // _fetchHistoryForMotorcycle calls getBranchesUseCase
        // which is already mocked to return empty [] in setUp,
        // so no FetchServiceHistory is dispatched.
        return bloc;
      },
      seed: () => SearchMotorcycleLoaded(testEntity),
      act: (bloc) => bloc.add(
        const UpdateServiceStatus(
          serviceId: 'svc-1',
          motorcycleId: 'moto-1',
          newStatus: 'EN_PROCESO',
        ),
      ),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        // isUpdatingStatus = true
        isA<SearchMotorcycleLoaded>()
            .having((s) => s.isUpdatingStatus, 'isUpdatingStatus', true)
            .having((s) => s.statusUpdateMessage, 'statusUpdateMessage', null)
            .having((s) => s.statusUpdateError, 'statusUpdateError', null),
        // isUpdatingStatus = false, message set
        isA<SearchMotorcycleLoaded>()
            .having((s) => s.isUpdatingStatus, 'isUpdatingStatus', false)
            .having(
              (s) => s.statusUpdateMessage,
              'statusUpdateMessage',
              'Estado actualizado exitosamente',
            ),
      ],
      verify: (_) {
        verify(
          mockUpdateServiceStatusUseCase.call(
            'svc-1',
            'EN_PROCESO',
            finalPrice: null,
          ),
        ).called(1);
      },
    );

    blocTest<SearchMotorcycleBloc, SearchMotorcycleState>(
      'emits error state on failure',
      build: () {
        when(
          mockUpdateServiceStatusUseCase.call(
            any,
            any,
            finalPrice: anyNamed('finalPrice'),
          ),
        ).thenAnswer(
          (_) async => Left(
            ErrorModel(errorCode: 'ERR', message: 'Transición no permitida'),
          ),
        );
        return bloc;
      },
      seed: () => SearchMotorcycleLoaded(testEntity),
      act: (bloc) => bloc.add(
        const UpdateServiceStatus(
          serviceId: 'svc-1',
          motorcycleId: 'moto-1',
          newStatus: 'INVALID',
        ),
      ),
      expect: () => [
        // isUpdatingStatus = true
        isA<SearchMotorcycleLoaded>().having(
          (s) => s.isUpdatingStatus,
          'isUpdatingStatus',
          true,
        ),
        // isUpdatingStatus = false, error set
        isA<SearchMotorcycleLoaded>()
            .having((s) => s.isUpdatingStatus, 'isUpdatingStatus', false)
            .having(
              (s) => s.statusUpdateError,
              'statusUpdateError',
              'Transición no permitida',
            ),
      ],
    );
  });

  // ─── FetchServiceTransitions Handler ─────────────────────────────

  group('FetchServiceTransitions Handler', () {
    blocTest<SearchMotorcycleBloc, SearchMotorcycleState>(
      'emits state with transitions on success',
      build: () {
        when(mockGetServiceTransitionsUseCase.call(any)).thenAnswer(
          (_) async => Right([
            StatusTransitionModel(
              id: 'trans-1',
              newStatus: 'PENDIENTE',
              createdBy: 'person-1',
              createdAt: DateTime(2026, 2, 16),
            ),
          ]),
        );
        return bloc;
      },
      seed: () => SearchMotorcycleLoaded(testEntity),
      act: (bloc) =>
          bloc.add(const FetchServiceTransitions(serviceId: 'svc-1')),
      expect: () => [
        isA<SearchMotorcycleLoaded>()
            .having((s) => s.serviceTransitions.length, 'transitions length', 1)
            .having(
              (s) => s.serviceTransitions[0].newStatus,
              'newStatus',
              'PENDIENTE',
            ),
      ],
      verify: (_) {
        verify(mockGetServiceTransitionsUseCase.call('svc-1')).called(1);
      },
    );

    blocTest<SearchMotorcycleBloc, SearchMotorcycleState>(
      'silently handles failure (no error state emitted)',
      build: () {
        when(mockGetServiceTransitionsUseCase.call(any)).thenAnswer(
          (_) async => Left(ErrorModel(errorCode: 'ERR', message: 'Error')),
        );
        return bloc;
      },
      seed: () => SearchMotorcycleLoaded(testEntity),
      act: (bloc) =>
          bloc.add(const FetchServiceTransitions(serviceId: 'svc-1')),
      expect: () => [], // No state change on failure (silent)
    );
  });

  // ─── DeleteCompletedService Handler ────────────────────────────────

  group('DeleteCompletedService Handler', () {
    blocTest<SearchMotorcycleBloc, SearchMotorcycleState>(
      'emits updated state on success',
      build: () {
        when(mockDeleteCompletedServiceUseCase.call(any)).thenAnswer(
          (_) async => const Right('Servicio eliminado exitosamente'),
        );
        return bloc;
      },
      seed: () => SearchMotorcycleLoaded(testEntity),
      act: (bloc) => bloc.add(
        const DeleteCompletedService(
          serviceId: 'svc-1',
          motorcycleId: 'moto-1',
        ),
      ),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        // isDeletingService = true
        isA<SearchMotorcycleLoaded>()
            .having((s) => s.isDeletingService, 'isDeletingService', true)
            .having((s) => s.deleteServiceMessage, 'deleteServiceMessage', null)
            .having((s) => s.deleteServiceError, 'deleteServiceError', null),
        // isDeletingService = false, message set
        isA<SearchMotorcycleLoaded>()
            .having((s) => s.isDeletingService, 'isDeletingService', false)
            .having(
              (s) => s.deleteServiceMessage,
              'deleteServiceMessage',
              'Servicio eliminado exitosamente',
            ),
      ],
      verify: (_) {
        verify(mockDeleteCompletedServiceUseCase.call('svc-1')).called(1);
      },
    );

    blocTest<SearchMotorcycleBloc, SearchMotorcycleState>(
      'emits error state on failure',
      build: () {
        when(mockDeleteCompletedServiceUseCase.call(any)).thenAnswer(
          (_) async => Left(
            ErrorModel(errorCode: 'ERR', message: 'No se puede eliminar'),
          ),
        );
        return bloc;
      },
      seed: () => SearchMotorcycleLoaded(testEntity),
      act: (bloc) => bloc.add(
        const DeleteCompletedService(
          serviceId: 'svc-1',
          motorcycleId: 'moto-1',
        ),
      ),
      expect: () => [
        isA<SearchMotorcycleLoaded>().having(
          (s) => s.isDeletingService,
          'isDeletingService',
          true,
        ),
        isA<SearchMotorcycleLoaded>()
            .having((s) => s.isDeletingService, 'isDeletingService', false)
            .having(
              (s) => s.deleteServiceError,
              'deleteServiceError',
              'No se puede eliminar',
            ),
      ],
    );
  });

  // ─── UpdateServiceDetails Handler ──────────────────────────────────

  group('UpdateServiceDetails Handler', () {
    blocTest<SearchMotorcycleBloc, SearchMotorcycleState>(
      'emits updated state on success',
      build: () {
        when(
          mockUpdateServiceDetailsUseCase.call(
            any,
            quotedPrice: anyNamed('quotedPrice'),
            finalPrice: anyNamed('finalPrice'),
            representativeNotes: anyNamed('representativeNotes'),
          ),
        ).thenAnswer(
          (_) async => const Right('Detalles actualizados exitosamente'),
        );
        return bloc;
      },
      seed: () => SearchMotorcycleLoaded(testEntity),
      act: (bloc) => bloc.add(
        const UpdateServiceDetails(
          serviceId: 'svc-1',
          motorcycleId: 'moto-1',
          quotedPrice: 200000,
          finalPrice: 180000,
          representativeNotes: 'Notas actualizadas',
        ),
      ),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        // isUpdatingDetails = true
        isA<SearchMotorcycleLoaded>()
            .having((s) => s.isUpdatingDetails, 'isUpdatingDetails', true)
            .having((s) => s.detailsUpdateMessage, 'detailsUpdateMessage', null)
            .having((s) => s.detailsUpdateError, 'detailsUpdateError', null),
        // isUpdatingDetails = false, message set
        isA<SearchMotorcycleLoaded>()
            .having((s) => s.isUpdatingDetails, 'isUpdatingDetails', false)
            .having(
              (s) => s.detailsUpdateMessage,
              'detailsUpdateMessage',
              'Detalles actualizados exitosamente',
            ),
      ],
    );

    blocTest<SearchMotorcycleBloc, SearchMotorcycleState>(
      'emits error state on failure',
      build: () {
        when(
          mockUpdateServiceDetailsUseCase.call(
            any,
            quotedPrice: anyNamed('quotedPrice'),
            finalPrice: anyNamed('finalPrice'),
            representativeNotes: anyNamed('representativeNotes'),
          ),
        ).thenAnswer(
          (_) async =>
              Left(ErrorModel(errorCode: 'ERR', message: 'Error actualizando')),
        );
        return bloc;
      },
      seed: () => SearchMotorcycleLoaded(testEntity),
      act: (bloc) => bloc.add(
        const UpdateServiceDetails(
          serviceId: 'svc-1',
          motorcycleId: 'moto-1',
          quotedPrice: 200000,
        ),
      ),
      expect: () => [
        isA<SearchMotorcycleLoaded>().having(
          (s) => s.isUpdatingDetails,
          'isUpdatingDetails',
          true,
        ),
        isA<SearchMotorcycleLoaded>()
            .having((s) => s.isUpdatingDetails, 'isUpdatingDetails', false)
            .having(
              (s) => s.detailsUpdateError,
              'detailsUpdateError',
              'Error actualizando',
            ),
      ],
    );

    blocTest<SearchMotorcycleBloc, SearchMotorcycleState>(
      'does nothing when state is not Loaded',
      build: () => bloc,
      act: (bloc) => bloc.add(
        const UpdateServiceDetails(
          serviceId: 'svc-1',
          motorcycleId: 'moto-1',
          quotedPrice: 200000,
        ),
      ),
      expect: () => [],
    );
  });

  // ─── FetchServiceHistory Handler ──────────────────────────────────

  group('FetchServiceHistory Handler', () {
    blocTest<SearchMotorcycleBloc, SearchMotorcycleState>(
      'emits state with services on success',
      build: () {
        when(
          mockGetServiceHistoryUseCase.call(
            motorcycleId: anyNamed('motorcycleId'),
            branchIds: anyNamed('branchIds'),
          ),
        ).thenAnswer(
          (_) async => Right([
            CompletedServiceEntity(
              id: 'cs-1',
              branchId: 'branch-1',
              motorcycleId: 'moto-123',
              status: 'FINALIZADO',
              requestDate: DateTime(2026, 1, 1),
              services: [],
            ),
          ]),
        );
        return bloc;
      },
      seed: () => SearchMotorcycleLoaded(testEntity),
      act: (bloc) => bloc.add(
        const FetchServiceHistory(
          motorcycleId: 'moto-123',
          branchIds: ['branch-1'],
        ),
      ),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        // loading = true
        isA<SearchMotorcycleLoaded>().having(
          (s) => s.loadingHistory,
          'loadingHistory',
          true,
        ),
        // loading = false, services set
        isA<SearchMotorcycleLoaded>()
            .having((s) => s.loadingHistory, 'loadingHistory', false)
            .having((s) => s.serviceHistory.length, 'serviceHistory count', 1),
      ],
    );

    blocTest<SearchMotorcycleBloc, SearchMotorcycleState>(
      'emits error state on failure',
      build: () {
        when(
          mockGetServiceHistoryUseCase.call(
            motorcycleId: anyNamed('motorcycleId'),
            branchIds: anyNamed('branchIds'),
          ),
        ).thenAnswer(
          (_) async => Left(
            ErrorModel(errorCode: 'ERR', message: 'Error al obtener historial'),
          ),
        );
        return bloc;
      },
      seed: () => SearchMotorcycleLoaded(testEntity),
      act: (bloc) => bloc.add(
        const FetchServiceHistory(
          motorcycleId: 'moto-123',
          branchIds: ['branch-1'],
        ),
      ),
      expect: () => [
        isA<SearchMotorcycleLoaded>().having(
          (s) => s.loadingHistory,
          'loadingHistory',
          true,
        ),
        isA<SearchMotorcycleLoaded>()
            .having((s) => s.loadingHistory, 'loadingHistory', false)
            .having(
              (s) => s.historyError,
              'historyError',
              'Error al obtener historial',
            ),
      ],
    );

    blocTest<SearchMotorcycleBloc, SearchMotorcycleState>(
      'does nothing when state is not Loaded',
      build: () => bloc,
      act: (bloc) => bloc.add(
        const FetchServiceHistory(
          motorcycleId: 'moto-123',
          branchIds: ['branch-1'],
        ),
      ),
      expect: () => [],
    );
  });

  // ─── Sub-state copyWith tests ──────────────────────────────────────

  group('ServiceRegistrationStatus', () {
    test('copyWith returns updated instance', () {
      const status = ServiceRegistrationStatus();
      final updated = status.copyWith(
        isRegistering: true,
        message: 'OK',
        error: 'Fail',
      );

      expect(updated.isRegistering, true);
      expect(updated.message, 'OK');
      expect(updated.error, 'Fail');
    });

    test('copyWith preserves isRegistering when not provided', () {
      const status = ServiceRegistrationStatus(isRegistering: true);
      final updated = status.copyWith(message: 'Done');

      expect(updated.isRegistering, true);
      expect(updated.message, 'Done');
    });

    test('props includes all fields', () {
      const status = ServiceRegistrationStatus(
        isRegistering: true,
        message: 'msg',
        error: 'err',
      );
      expect(status.props, [true, 'msg', 'err']);
    });
  });

  group('ServiceHistoryStatus', () {
    test('copyWith returns updated instance', () {
      const status = ServiceHistoryStatus();
      final updated = status.copyWith(loading: true, error: 'Error');

      expect(updated.loading, true);
      expect(updated.error, 'Error');
      expect(updated.services, isEmpty);
    });

    test('copyWith preserves services when not provided', () {
      final service = CompletedServiceEntity(
        id: 'cs-1',
        branchId: 'b-1',
        motorcycleId: 'm-1',
        status: 'FINALIZADO',
        requestDate: DateTime(2026, 1, 1),
        services: [],
      );
      final status = ServiceHistoryStatus(services: [service]);
      final updated = status.copyWith(loading: true);

      expect(updated.services, hasLength(1));
    });

    test('props includes all fields', () {
      const status = ServiceHistoryStatus(loading: true, error: 'e');
      expect(status.props, [const [], true, 'e', const []]);
    });
  });

  group('ServiceActionStatus', () {
    test('copyWith returns updated instance with all fields', () {
      const status = ServiceActionStatus();
      final updated = status.copyWith(
        statusUpdate: const AsyncActionState(
          isLoading: true,
          message: 'Status OK',
          error: 'Status Err',
        ),
        detailsUpdate: const AsyncActionState(
          isLoading: true,
          message: 'Details OK',
          error: 'Details Err',
        ),
        deleteAction: const AsyncActionState(
          isLoading: true,
          message: 'Delete OK',
          error: 'Delete Err',
        ),
      );

      expect(updated.isUpdatingStatus, true);
      expect(updated.statusUpdateMessage, 'Status OK');
      expect(updated.statusUpdateError, 'Status Err');
      expect(updated.isUpdatingDetails, true);
      expect(updated.detailsUpdateMessage, 'Details OK');
      expect(updated.detailsUpdateError, 'Details Err');
      expect(updated.isDeletingService, true);
      expect(updated.deleteServiceMessage, 'Delete OK');
      expect(updated.deleteServiceError, 'Delete Err');
    });

    test('copyWith preserves sub-states when not provided', () {
      const status = ServiceActionStatus(
        statusUpdate: AsyncActionState(isLoading: true),
        detailsUpdate: AsyncActionState(isLoading: true),
        deleteAction: AsyncActionState(isLoading: true),
      );
      final updated = status.copyWith(
        statusUpdate: const AsyncActionState(isLoading: true, message: 'msg'),
      );

      expect(updated.isUpdatingStatus, true);
      expect(updated.isUpdatingDetails, true);
      expect(updated.isDeletingService, true);
    });

    test('props includes all sub-states', () {
      const status = ServiceActionStatus();
      expect(status.props.length, 3);
    });
  });
}
