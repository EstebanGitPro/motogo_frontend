import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/manage_franchise/domain/usecases/franchise_usecases.dart';
import 'package:motogo_frontend/src/features/my_branches/domain/usecases/get_branches_usecase.dart';
import 'package:motogo_frontend/src/features/my_branches/presentation/bloc/my_branches_bloc.dart';
import 'package:motogo_frontend/src/features/my_branches/presentation/bloc/my_branches_event.dart';
import 'package:motogo_frontend/src/features/my_branches/presentation/bloc/my_branches_state.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';
import 'package:motogo_frontend/src/features/register_franchise/domain/entities/franchise_entity.dart';

import 'my_branches_full_bloc_test.mocks.dart';

@GenerateMocks([GetBranchesUseCase, ListFranchisesUseCase])
void main() {
  late MockGetBranchesUseCase mockGetBranches;
  late MockListFranchisesUseCase mockListFranchises;

  const testLocation = BranchLocation(
    address: 'Calle 100',
    cityId: 'city-1',
    departmentId: 'dep-1',
  );

  final testBranches = <BranchEntity>[
    const BranchEntity(
      id: 'br-1',
      name: 'Sede Norte',
      establishmentType: 'WORKSHOP',
      franchiseId: 'fr-1',
      location: testLocation,
    ),
    const BranchEntity(
      id: 'br-2',
      name: 'Sede Sur Centro',
      establishmentType: 'STORE',
      location: testLocation,
    ),
  ];

  const testFranchises = <FranchiseEntity>[
    FranchiseEntity(id: 'fr-1', name: 'MotoGo Premium', branchIds: ['br-1']),
  ];

  setUpAll(() {
    provideDummy<Either<ErrorModel, List<BranchEntity>>>(
      const Right(<BranchEntity>[]),
    );
    provideDummy<Either<ErrorModel, List<FranchiseEntity>>>(
      const Right(<FranchiseEntity>[]),
    );
  });

  setUp(() {
    mockGetBranches = MockGetBranchesUseCase();
    mockListFranchises = MockListFranchisesUseCase();
  });

  MyBranchesBloc buildBloc() => MyBranchesBloc(
    getBranchesUseCase: mockGetBranches,
    listFranchisesUseCase: mockListFranchises,
  );

  group('MyBranchesBloc', () {
    test('initial state is MyBranchesInitial', () {
      expect(buildBloc().state, isA<MyBranchesInitial>());
    });

    group('LoadBranches', () {
      blocTest<MyBranchesBloc, MyBranchesState>(
        'emits [Loading, Loaded] with branches and franchise info',
        setUp: () {
          when(mockGetBranches.call()).thenAnswer(
            (_) async => Right<ErrorModel, List<BranchEntity>>(testBranches),
          );
          when(
            mockListFranchises.call(),
          ).thenAnswer((_) async => const Right(testFranchises));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(LoadBranches()),
        expect: () => [
          isA<MyBranchesLoading>(),
          isA<MyBranchesLoaded>()
              .having((s) => s.branches.length, 'branches', 2)
              .having(
                (s) => s.franchiseNames['fr-1'],
                'franchise',
                'MotoGo Premium',
              )
              .having(
                (s) => s.branchesWithFranchise.contains('br-1'),
                'hasFranchise',
                true,
              ),
        ],
      );

      blocTest<MyBranchesBloc, MyBranchesState>(
        'emits [Loading, Error] on failure',
        setUp: () {
          when(
            mockGetBranches.call(),
          ).thenAnswer((_) async => Left(ErrorModel(message: 'Sin conexión')));
          when(
            mockListFranchises.call(),
          ).thenAnswer((_) async => const Right(<FranchiseEntity>[]));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(LoadBranches()),
        expect: () => [isA<MyBranchesLoading>(), isA<MyBranchesError>()],
      );
    });

    group('RefreshBranches', () {
      blocTest<MyBranchesBloc, MyBranchesState>(
        'emits [Loaded] without loading state',
        setUp: () {
          when(mockGetBranches.call()).thenAnswer(
            (_) async => Right<ErrorModel, List<BranchEntity>>(testBranches),
          );
          when(
            mockListFranchises.call(),
          ).thenAnswer((_) async => const Right(testFranchises));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(RefreshBranches()),
        expect: () => [
          isA<MyBranchesLoaded>().having(
            (s) => s.branches.length,
            'branches',
            2,
          ),
        ],
      );
    });

    group('SearchBranches', () {
      blocTest<MyBranchesBloc, MyBranchesState>(
        'filters branches by name',
        setUp: () {
          when(mockGetBranches.call()).thenAnswer(
            (_) async => Right<ErrorModel, List<BranchEntity>>(testBranches),
          );
          when(
            mockListFranchises.call(),
          ).thenAnswer((_) async => const Right(testFranchises));
        },
        build: buildBloc,
        act: (bloc) async {
          bloc.add(LoadBranches());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(SearchBranches(query: 'Norte'));
        },
        skip: 2,
        expect: () => [
          isA<MyBranchesLoaded>()
              .having((s) => s.filteredBranches.length, 'filtered', 1)
              .having(
                (s) => s.filteredBranches.first.name,
                'name',
                'Sede Norte',
              ),
        ],
      );

      blocTest<MyBranchesBloc, MyBranchesState>(
        'resets filter on empty query',
        setUp: () {
          when(mockGetBranches.call()).thenAnswer(
            (_) async => Right<ErrorModel, List<BranchEntity>>(testBranches),
          );
          when(
            mockListFranchises.call(),
          ).thenAnswer((_) async => const Right(testFranchises));
        },
        build: buildBloc,
        act: (bloc) async {
          bloc.add(LoadBranches());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(SearchBranches(query: 'Norte'));
          await Future.delayed(const Duration(milliseconds: 50));
          bloc.add(SearchBranches(query: ''));
        },
        skip: 3,
        expect: () => [
          isA<MyBranchesLoaded>().having(
            (s) => s.filteredBranches.length,
            'filtered',
            2,
          ),
        ],
      );
    });
  });
}
