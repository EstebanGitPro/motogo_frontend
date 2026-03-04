import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/service_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/repositories/catalogs_repository.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/branch_services/data/datasources/branch_services_datasource.dart';
import 'package:motogo_frontend/src/features/branch_services/data/models/branch_service_model.dart';
import 'package:motogo_frontend/src/features/branch_services/presentation/bloc/branch_services_bloc.dart';
import 'package:motogo_frontend/src/features/branch_services/presentation/bloc/branch_services_event.dart';
import 'package:motogo_frontend/src/features/branch_services/presentation/bloc/branch_services_state.dart';

import 'branch_services_full_bloc_test.mocks.dart';

@GenerateMocks([CatalogsRepository, BranchServicesDataSource])
void main() {
  late MockCatalogsRepository mockCatalogs;
  late MockBranchServicesDataSource mockBranchServices;

  const testCatalogServices = [
    ServiceEntity(
      id: 'svc-1',
      name: 'Cambio de aceite',
      description: 'Cambio completo',
      serviceType: 'Mantenimiento',
    ),
    ServiceEntity(
      id: 'svc-2',
      name: 'Revisión frenos',
      description: 'Inspección completa',
      serviceType: 'Seguridad',
    ),
    ServiceEntity(
      id: 'svc-3',
      name: 'Alineación',
      description: 'Balanceo y alineación',
      serviceType: 'Mantenimiento',
    ),
  ];

  setUpAll(() {
    provideDummy<Either<ErrorModel, List<ServiceEntity>>>(
      const Right(<ServiceEntity>[]),
    );
    provideDummy<Either<ErrorModel, List<BranchServiceModel>>>(
      const Right(<BranchServiceModel>[]),
    );
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockCatalogs = MockCatalogsRepository();
    mockBranchServices = MockBranchServicesDataSource();
  });

  BranchServicesBloc buildBloc() => BranchServicesBloc(
    catalogsRepository: mockCatalogs,
    branchServicesDataSource: mockBranchServices,
  );

  group('BranchServicesBloc', () {
    test('initial state is BranchServicesInitial', () {
      expect(buildBloc().state, isA<BranchServicesInitial>());
    });

    group('LoadBranchServices', () {
      blocTest<BranchServicesBloc, BranchServicesState>(
        'emits [Loading, Loaded] with catalog and branch services',
        setUp: () {
          when(
            mockCatalogs.getServices(),
          ).thenAnswer((_) async => const Right(testCatalogServices));
          when(
            mockBranchServices.getBranchServices('br-1'),
          ).thenAnswer((_) async => const Right(<BranchServiceModel>[]));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(LoadBranchServices('br-1')),
        expect: () => [
          isA<BranchServicesLoading>(),
          isA<BranchServicesLoaded>()
              .having((s) => s.allServices.length, 'allServices', 3)
              .having((s) => s.displayedServices.length, 'displayed', 3)
              .having((s) => s.branchServices.length, 'branchServices', 0),
        ],
      );

      blocTest<BranchServicesBloc, BranchServicesState>(
        'emits [Loading, Error] on catalog failure',
        setUp: () {
          when(
            mockCatalogs.getServices(),
          ).thenAnswer((_) async => Left(ErrorModel(message: 'Sin conexión')));
          when(
            mockBranchServices.getBranchServices('br-1'),
          ).thenAnswer((_) async => const Right(<BranchServiceModel>[]));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(LoadBranchServices('br-1')),
        expect: () => [
          isA<BranchServicesLoading>(),
          isA<BranchServicesError>().having(
            (s) => s.message,
            'message',
            'Sin conexión',
          ),
        ],
      );
    });

    group('SearchServices', () {
      blocTest<BranchServicesBloc, BranchServicesState>(
        'filters services by query',
        setUp: () {
          when(
            mockCatalogs.getServices(),
          ).thenAnswer((_) async => const Right(testCatalogServices));
          when(
            mockBranchServices.getBranchServices('br-1'),
          ).thenAnswer((_) async => const Right(<BranchServiceModel>[]));
        },
        build: buildBloc,
        act: (bloc) async {
          bloc.add(LoadBranchServices('br-1'));
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(SearchServices('aceite'));
        },
        skip: 2,
        expect: () => [
          isA<BranchServicesLoaded>()
              .having((s) => s.displayedServices.length, 'displayed', 1)
              .having((s) => s.searchQuery, 'query', 'aceite'),
        ],
      );
    });

    group('FilterServicesByType', () {
      blocTest<BranchServicesBloc, BranchServicesState>(
        'filters services by type',
        setUp: () {
          when(
            mockCatalogs.getServices(),
          ).thenAnswer((_) async => const Right(testCatalogServices));
          when(
            mockBranchServices.getBranchServices('br-1'),
          ).thenAnswer((_) async => const Right(<BranchServiceModel>[]));
        },
        build: buildBloc,
        act: (bloc) async {
          bloc.add(LoadBranchServices('br-1'));
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(FilterServicesByType('Seguridad'));
        },
        skip: 2,
        expect: () => [
          isA<BranchServicesLoaded>()
              .having((s) => s.displayedServices.length, 'displayed', 1)
              .having((s) => s.filterType, 'filterType', 'Seguridad'),
        ],
      );
    });

    group('ToggleServiceAssociation', () {
      blocTest<BranchServicesBloc, BranchServicesState>(
        'associates a service (optimistic update + API)',
        setUp: () {
          when(
            mockCatalogs.getServices(),
          ).thenAnswer((_) async => const Right(testCatalogServices));
          when(
            mockBranchServices.getBranchServices('br-1'),
          ).thenAnswer((_) async => const Right(<BranchServiceModel>[]));
          when(
            mockBranchServices.associateService('br-1', 'svc-1'),
          ).thenAnswer((_) async => const Right('Servicio asociado'));
        },
        build: buildBloc,
        act: (bloc) async {
          bloc.add(LoadBranchServices('br-1'));
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(
            ToggleServiceAssociation(serviceId: 'svc-1', associate: true),
          );
        },
        skip: 2,
        expect: () => [
          // Optimistic: branchServices now has 1
          isA<BranchServicesLoaded>().having(
            (s) => s.branchServices.length,
            'branchServices',
            1,
          ),
          // API success: message emitted
          isA<BranchServicesLoaded>()
              .having((s) => s.message, 'message', 'Servicio asociado')
              .having((s) => s.isSuccess, 'isSuccess', true),
        ],
      );

      blocTest<BranchServicesBloc, BranchServicesState>(
        'dissociates a service',
        setUp: () {
          when(
            mockCatalogs.getServices(),
          ).thenAnswer((_) async => const Right(testCatalogServices));
          when(
            mockBranchServices.getBranchServices('br-1'),
          ).thenAnswer((_) async => const Right(<BranchServiceModel>[]));
          when(
            mockBranchServices.dissociateService('br-1', 'svc-1'),
          ).thenAnswer((_) async => const Right('Servicio desasociado'));
        },
        build: buildBloc,
        act: (bloc) async {
          bloc.add(LoadBranchServices('br-1'));
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(
            ToggleServiceAssociation(serviceId: 'svc-1', associate: false),
          );
        },
        skip: 2,
        expect: () => [
          // Optimistic remove is a no-op (list was empty) so BLoC deduplicates.
          // Only the API success state is emitted.
          isA<BranchServicesLoaded>()
              .having((s) => s.branchServices.length, 'branchServices', 0)
              .having((s) => s.message, 'message', 'Servicio desasociado')
              .having((s) => s.isSuccess, 'isSuccess', true),
        ],
      );
    });
  });
}
