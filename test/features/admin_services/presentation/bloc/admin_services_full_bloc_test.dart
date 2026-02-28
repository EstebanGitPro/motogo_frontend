import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/admin_services/domain/entities/admin_service_entity.dart';
import 'package:motogo_frontend/src/features/admin_services/domain/usecases/admin_service_usecases.dart';
import 'package:motogo_frontend/src/features/admin_services/presentation/bloc/admin_services_bloc.dart';
import 'package:motogo_frontend/src/features/admin_services/presentation/bloc/admin_services_event.dart';
import 'package:motogo_frontend/src/features/admin_services/presentation/bloc/admin_services_state.dart';

import 'admin_services_full_bloc_test.mocks.dart';

@GenerateMocks([
  GetServicesCatalogUseCase,
  UpdateServiceUseCase,
  ActivateServiceUseCase,
  DeactivateServiceUseCase,
])
void main() {
  late MockGetServicesCatalogUseCase mockGetServices;
  late MockUpdateServiceUseCase mockUpdateService;
  late MockActivateServiceUseCase mockActivateService;
  late MockDeactivateServiceUseCase mockDeactivateService;

  const testServices = [
    AdminServiceEntity(
      id: 'svc-1',
      name: 'Cambio de aceite',
      serviceType: 'Mantenimiento',
      isActive: true,
      description: 'Cambio completo de aceite',
    ),
    AdminServiceEntity(
      id: 'svc-2',
      name: 'Revisión de frenos',
      serviceType: 'Seguridad',
      isActive: true,
    ),
    AdminServiceEntity(
      id: 'svc-3',
      name: 'Alineación',
      serviceType: 'Mantenimiento',
      isActive: false,
    ),
  ];

  setUpAll(() {
    provideDummy<Either<ErrorModel, List<AdminServiceEntity>>>(
      const Right(<AdminServiceEntity>[]),
    );
    provideDummy<Either<ErrorModel, AdminServiceEntity>>(
      const Right(
        AdminServiceEntity(id: '', name: '', serviceType: '', isActive: false),
      ),
    );
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockGetServices = MockGetServicesCatalogUseCase();
    mockUpdateService = MockUpdateServiceUseCase();
    mockActivateService = MockActivateServiceUseCase();
    mockDeactivateService = MockDeactivateServiceUseCase();
  });

  AdminServicesBloc buildBloc() => AdminServicesBloc(
    getServicesUseCase: mockGetServices,
    updateServiceUseCase: mockUpdateService,
    activateServiceUseCase: mockActivateService,
    deactivateServiceUseCase: mockDeactivateService,
  );

  group('AdminServicesBloc', () {
    test('initial state is AdminServicesInitial', () {
      expect(buildBloc().state, isA<AdminServicesInitial>());
    });

    // ========== LoadServices ==========

    group('LoadServices', () {
      blocTest<AdminServicesBloc, AdminServicesState>(
        'emits [Loading, Loaded] with services on success',
        setUp: () {
          when(
            mockGetServices.call(),
          ).thenAnswer((_) async => const Right(testServices));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(LoadServices()),
        expect: () => [
          isA<AdminServicesLoading>(),
          isA<AdminServicesLoaded>()
              .having((s) => s.allServices.length, 'allServices', 3)
              .having((s) => s.filteredServices.length, 'filteredServices', 3)
              .having(
                (s) => s.availableTypes.length,
                'availableTypes',
                2, // Mantenimiento, Seguridad (sorted)
              ),
        ],
      );

      blocTest<AdminServicesBloc, AdminServicesState>(
        'emits [Loading, Error] on failure',
        setUp: () {
          when(
            mockGetServices.call(),
          ).thenAnswer((_) async => Left(ErrorModel(message: 'Error')));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(LoadServices()),
        expect: () => [isA<AdminServicesLoading>(), isA<AdminServicesError>()],
      );
    });

    // ========== RefreshServices ==========

    group('RefreshServices', () {
      blocTest<AdminServicesBloc, AdminServicesState>(
        'emits [Loaded] without loading state',
        setUp: () {
          when(
            mockGetServices.call(),
          ).thenAnswer((_) async => const Right(testServices));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(RefreshServices()),
        expect: () => [
          // No Loading state emitted for refresh
          isA<AdminServicesLoaded>().having(
            (s) => s.allServices.length,
            'allServices',
            3,
          ),
        ],
      );
    });

    // ========== SearchServices ==========

    group('SearchServices', () {
      blocTest<AdminServicesBloc, AdminServicesState>(
        'filters services by query',
        setUp: () {
          when(
            mockGetServices.call(),
          ).thenAnswer((_) async => const Right(testServices));
        },
        build: buildBloc,
        act: (bloc) async {
          bloc.add(LoadServices());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(SearchServices(query: 'aceite'));
        },
        skip: 2, // Skip Loading + initial Loaded
        expect: () => [
          isA<AdminServicesLoaded>()
              .having((s) => s.filteredServices.length, 'filteredServices', 1)
              .having(
                (s) => s.filteredServices.first.name,
                'name',
                'Cambio de aceite',
              )
              .having((s) => s.searchQuery, 'searchQuery', 'aceite'),
        ],
      );

      blocTest<AdminServicesBloc, AdminServicesState>(
        'filters services by type',
        setUp: () {
          when(
            mockGetServices.call(),
          ).thenAnswer((_) async => const Right(testServices));
        },
        build: buildBloc,
        act: (bloc) async {
          bloc.add(LoadServices());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(SearchServices(query: '', typeFilter: 'Seguridad'));
        },
        skip: 2,
        expect: () => [
          isA<AdminServicesLoaded>()
              .having((s) => s.filteredServices.length, 'filteredServices', 1)
              .having((s) => s.typeFilter, 'typeFilter', 'Seguridad'),
        ],
      );
    });

    // ========== ToggleServiceStatus ==========

    group('ToggleServiceStatus', () {
      blocTest<AdminServicesBloc, AdminServicesState>(
        'emits [Updating, UpdateSuccess] when deactivating',
        setUp: () {
          when(
            mockGetServices.call(),
          ).thenAnswer((_) async => const Right(testServices));
          when(
            mockDeactivateService.call('svc-1'),
          ).thenAnswer((_) async => const Right('Servicio desactivado'));
        },
        build: buildBloc,
        act: (bloc) async {
          bloc.add(LoadServices());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(
            const ToggleServiceStatus(serviceId: 'svc-1', activate: false),
          );
        },
        skip: 2,
        expect: () => [
          isA<AdminServicesUpdating>().having(
            (s) => s.updatingServiceId,
            'updatingServiceId',
            'svc-1',
          ),
          isA<AdminServicesUpdateSuccess>().having(
            (s) => s.message,
            'message',
            'Servicio desactivado',
          ),
        ],
      );

      blocTest<AdminServicesBloc, AdminServicesState>(
        'emits [Updating, UpdateSuccess] when activating',
        setUp: () {
          when(
            mockGetServices.call(),
          ).thenAnswer((_) async => const Right(testServices));
          when(
            mockActivateService.call('svc-3'),
          ).thenAnswer((_) async => const Right('Servicio activado'));
        },
        build: buildBloc,
        act: (bloc) async {
          bloc.add(LoadServices());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(
            const ToggleServiceStatus(serviceId: 'svc-3', activate: true),
          );
        },
        skip: 2,
        expect: () => [
          isA<AdminServicesUpdating>(),
          isA<AdminServicesUpdateSuccess>().having(
            (s) => s.message,
            'message',
            'Servicio activado',
          ),
        ],
      );
    });

    // ========== UpdateService ==========

    group('UpdateService', () {
      blocTest<AdminServicesBloc, AdminServicesState>(
        'emits [Updating, UpdateSuccess] on success',
        setUp: () {
          when(
            mockGetServices.call(),
          ).thenAnswer((_) async => const Right(testServices));
          when(
            mockUpdateService.call(
              serviceId: 'svc-1',
              name: 'Cambio de aceite premium',
              serviceType: 'Mantenimiento',
              description: 'Nuevo desc',
              isActive: true,
            ),
          ).thenAnswer(
            (_) async => const Right(
              AdminServiceEntity(
                id: 'svc-1',
                name: 'Cambio de aceite premium',
                serviceType: 'Mantenimiento',
                description: 'Nuevo desc',
                isActive: true,
              ),
            ),
          );
        },
        build: buildBloc,
        act: (bloc) async {
          bloc.add(LoadServices());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(
            const UpdateService(
              serviceId: 'svc-1',
              name: 'Cambio de aceite premium',
              serviceType: 'Mantenimiento',
              description: 'Nuevo desc',
              isActive: true,
            ),
          );
        },
        skip: 2,
        expect: () => [
          isA<AdminServicesUpdating>().having(
            (s) => s.updatingServiceId,
            'updatingServiceId',
            'svc-1',
          ),
          isA<AdminServicesUpdateSuccess>().having(
            (s) => s.message,
            'message',
            'Servicio actualizado exitosamente',
          ),
        ],
      );

      blocTest<AdminServicesBloc, AdminServicesState>(
        'emits [Updating, Error, restored Loaded] on failure',
        setUp: () {
          when(
            mockGetServices.call(),
          ).thenAnswer((_) async => const Right(testServices));
          when(
            mockUpdateService.call(
              serviceId: 'svc-1',
              name: 'Fail',
              serviceType: 'Mantenimiento',
            ),
          ).thenAnswer(
            (_) async => Left(ErrorModel(message: 'Error actualizando')),
          );
        },
        build: buildBloc,
        act: (bloc) async {
          bloc.add(LoadServices());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(
            const UpdateService(
              serviceId: 'svc-1',
              name: 'Fail',
              serviceType: 'Mantenimiento',
            ),
          );
        },
        skip: 2,
        expect: () => [
          isA<AdminServicesUpdating>(),
          isA<AdminServicesError>(),
          isA<AdminServicesLoaded>(), // Restored previous state
        ],
      );
    });
  });
}
