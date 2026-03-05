import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/manage_franchise/domain/usecases/franchise_usecases.dart';
import 'package:motogo_frontend/src/features/manage_franchise/presentation/bloc/manage_franchise_bloc.dart';
import 'package:motogo_frontend/src/features/manage_franchise/presentation/bloc/manage_franchise_event.dart';
import 'package:motogo_frontend/src/features/manage_franchise/presentation/bloc/manage_franchise_state.dart';
import 'package:motogo_frontend/src/features/my_branches/domain/usecases/get_branches_usecase.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';
import 'package:motogo_frontend/src/features/register_franchise/domain/entities/franchise_entity.dart';

import 'manage_franchise_full_bloc_test.mocks.dart';

@GenerateMocks([
  GetFranchiseUseCase,
  UpdateFranchiseUseCase,
  DeleteFranchiseUseCase,
  LinkBranchToFranchiseUseCase,
  UnlinkBranchFromFranchiseUseCase,
  GetBranchesUseCase,
])
void main() {
  late MockGetFranchiseUseCase mockGetFranchise;
  late MockUpdateFranchiseUseCase mockUpdateFranchise;
  late MockDeleteFranchiseUseCase mockDeleteFranchise;
  late MockLinkBranchToFranchiseUseCase mockLinkBranch;
  late MockUnlinkBranchFromFranchiseUseCase mockUnlinkBranch;
  late MockGetBranchesUseCase mockGetBranches;

  const testFranchise = FranchiseEntity(
    id: 'fr-1',
    name: 'MotoGo Premium',
    description: 'Red premium',
  );

  const testLocation = BranchLocation(
    address: 'Calle 1',
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
      name: 'Sede Sur',
      establishmentType: 'STORE',
      franchiseId: null,
      location: testLocation,
    ),
  ];

  setUpAll(() {
    provideDummy<Either<ErrorModel, FranchiseEntity>>(
      const Right(FranchiseEntity(name: '')),
    );
    provideDummy<Either<ErrorModel, List<BranchEntity>>>(
      const Right(<BranchEntity>[]),
    );
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockGetFranchise = MockGetFranchiseUseCase();
    mockUpdateFranchise = MockUpdateFranchiseUseCase();
    mockDeleteFranchise = MockDeleteFranchiseUseCase();
    mockLinkBranch = MockLinkBranchToFranchiseUseCase();
    mockUnlinkBranch = MockUnlinkBranchFromFranchiseUseCase();
    mockGetBranches = MockGetBranchesUseCase();
  });

  ManageFranchiseBloc buildBloc() => ManageFranchiseBloc(
    getFranchiseUseCase: mockGetFranchise,
    updateFranchiseUseCase: mockUpdateFranchise,
    deleteFranchiseUseCase: mockDeleteFranchise,
    linkBranchUseCase: mockLinkBranch,
    unlinkBranchUseCase: mockUnlinkBranch,
    getBranchesUseCase: mockGetBranches,
  );

  group('ManageFranchiseBloc', () {
    test('initial state is ManageFranchiseLoading', () {
      expect(buildBloc().state, isA<ManageFranchiseLoading>());
    });

    group('LoadFranchise', () {
      blocTest<ManageFranchiseBloc, ManageFranchiseState>(
        'emits [Loading, Loaded] on success',
        setUp: () {
          when(
            mockGetFranchise.call('fr-1'),
          ).thenAnswer((_) async => const Right(testFranchise));
          when(mockGetBranches.call()).thenAnswer(
            (_) async => Right<ErrorModel, List<BranchEntity>>(testBranches),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const LoadFranchise('fr-1')),
        expect: () => [
          isA<ManageFranchiseLoading>(),
          isA<ManageFranchiseLoaded>()
              .having((s) => s.franchise.name, 'name', 'MotoGo Premium')
              .having((s) => s.linkedBranches.length, 'linked', 1)
              .having((s) => s.availableBranches.length, 'available', 1),
        ],
      );

      blocTest<ManageFranchiseBloc, ManageFranchiseState>(
        'emits [Loading, Error] on franchise load failure',
        setUp: () {
          when(
            mockGetFranchise.call('fr-1'),
          ).thenAnswer((_) async => Left(ErrorModel(message: 'No encontrada')));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const LoadFranchise('fr-1')),
        expect: () => [
          isA<ManageFranchiseLoading>(),
          isA<ManageFranchiseError>().having(
            (s) => s.message,
            'message',
            'No encontrada',
          ),
        ],
      );

      blocTest<ManageFranchiseBloc, ManageFranchiseState>(
        'emits [Loading, Error] on branches load failure',
        setUp: () {
          when(
            mockGetFranchise.call('fr-1'),
          ).thenAnswer((_) async => const Right(testFranchise));
          when(
            mockGetBranches.call(),
          ).thenAnswer((_) async => Left(ErrorModel(message: 'Error sedes')));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const LoadFranchise('fr-1')),
        expect: () => [
          isA<ManageFranchiseLoading>(),
          isA<ManageFranchiseError>().having(
            (s) => s.message,
            'message',
            'Error sedes',
          ),
        ],
      );
    });

    group('DeleteFranchise', () {
      blocTest<ManageFranchiseBloc, ManageFranchiseState>(
        'emits [Deleted] on success',
        setUp: () {
          when(
            mockGetFranchise.call('fr-1'),
          ).thenAnswer((_) async => const Right(testFranchise));
          when(mockGetBranches.call()).thenAnswer(
            (_) async => Right<ErrorModel, List<BranchEntity>>(testBranches),
          );
          when(
            mockDeleteFranchise.call('fr-1'),
          ).thenAnswer((_) async => const Right('Franquicia eliminada'));
        },
        build: buildBloc,
        act: (bloc) async {
          bloc.add(const LoadFranchise('fr-1'));
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(const DeleteFranchiseEvent());
        },
        skip: 2,
        expect: () => [
          isA<ManageFranchiseDeleted>().having(
            (s) => s.message,
            'message',
            'Franquicia eliminada',
          ),
        ],
      );

      blocTest<ManageFranchiseBloc, ManageFranchiseState>(
        'emits [Error] on failure',
        setUp: () {
          when(
            mockGetFranchise.call('fr-1'),
          ).thenAnswer((_) async => const Right(testFranchise));
          when(mockGetBranches.call()).thenAnswer(
            (_) async => Right<ErrorModel, List<BranchEntity>>(testBranches),
          );
          when(mockDeleteFranchise.call('fr-1')).thenAnswer(
            (_) async => Left(ErrorModel(message: 'No se puede eliminar')),
          );
        },
        build: buildBloc,
        act: (bloc) async {
          bloc.add(const LoadFranchise('fr-1'));
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(const DeleteFranchiseEvent());
        },
        skip: 2,
        expect: () => [
          isA<ManageFranchiseError>().having(
            (s) => s.message,
            'message',
            'No se puede eliminar',
          ),
        ],
      );
    });

    group('UpdateFranchise', () {
      blocTest<ManageFranchiseBloc, ManageFranchiseState>(
        'emits [Updated, Loading, Loaded] on success (reloads)',
        setUp: () {
          when(
            mockGetFranchise.call('fr-1'),
          ).thenAnswer((_) async => const Right(testFranchise));
          when(mockGetBranches.call()).thenAnswer(
            (_) async => Right<ErrorModel, List<BranchEntity>>(testBranches),
          );
          when(mockUpdateFranchise.call('fr-1', any)).thenAnswer(
            (_) async => const Right(
              FranchiseEntity(
                id: 'fr-1',
                name: 'MotoGo Gold',
                description: 'Red gold',
              ),
            ),
          );
        },
        build: buildBloc,
        act: (bloc) async {
          bloc.add(const LoadFranchise('fr-1'));
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(
            const UpdateFranchiseEvent(
              name: 'MotoGo Gold',
              description: 'Red gold',
            ),
          );
        },
        skip: 2,
        expect: () => [
          isA<ManageFranchiseUpdated>()
              .having((s) => s.franchise.name, 'name', 'MotoGo Gold')
              .having((s) => s.message, 'message', 'Franquicia actualizada'),
          isA<ManageFranchiseLoading>(),
          isA<ManageFranchiseLoaded>(),
        ],
      );
    });
  });
}
