import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/edit_branch/domain/usecases/update_branch_usecase.dart';
import 'package:motogo_frontend/src/features/edit_branch/presentation/bloc/edit_branch_bloc.dart';
import 'package:motogo_frontend/src/features/edit_branch/presentation/bloc/edit_branch_event.dart';
import 'package:motogo_frontend/src/features/edit_branch/presentation/bloc/edit_branch_state.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';

import 'edit_branch_full_bloc_test.mocks.dart';

@GenerateMocks([UpdateBranchUseCase])
void main() {
  late MockUpdateBranchUseCase mockUpdateBranch;

  const testLocation = BranchLocation(
    address: 'Calle 100',
    cityId: 'city-1',
    departmentId: 'dep-1',
  );

  const testBranch = BranchEntity(
    id: 'br-1',
    name: 'Sede Norte',
    establishmentType: 'WORKSHOP',
    location: testLocation,
  );

  const updatedBranch = BranchEntity(
    id: 'br-1',
    name: 'Sede Norte Actualizada',
    establishmentType: 'WORKSHOP',
    location: testLocation,
  );

  setUpAll(() {
    provideDummy<Either<ErrorModel, (BranchEntity, String)>>(
      const Right((testBranch, 'ok')),
    );
  });

  setUp(() {
    mockUpdateBranch = MockUpdateBranchUseCase();
  });

  EditBranchBloc buildBloc() =>
      EditBranchBloc(updateBranchUseCase: mockUpdateBranch);

  group('EditBranchBloc', () {
    test('initial state is EditBranchInitial', () {
      expect(buildBloc().state, isA<EditBranchInitial>());
    });

    blocTest<EditBranchBloc, EditBranchState>(
      'emits [Loading, Success] on successful update',
      setUp: () {
        when(mockUpdateBranch.call('br-1', any)).thenAnswer(
          (_) async => const Right((updatedBranch, 'Sede actualizada')),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        EditBranchSubmitted(branchId: 'br-1', branch: updatedBranch),
      ),
      expect: () => [
        isA<EditBranchLoading>(),
        isA<EditBranchSuccess>()
            .having((s) => s.message, 'message', 'Sede actualizada')
            .having(
              (s) => s.updatedBranch.name,
              'name',
              'Sede Norte Actualizada',
            ),
      ],
    );

    blocTest<EditBranchBloc, EditBranchState>(
      'emits [Loading, Failure] on error',
      setUp: () {
        when(mockUpdateBranch.call('br-1', any)).thenAnswer(
          (_) async => Left(ErrorModel(message: 'Error al actualizar')),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        EditBranchSubmitted(branchId: 'br-1', branch: updatedBranch),
      ),
      expect: () => [isA<EditBranchLoading>(), isA<EditBranchFailure>()],
    );

    blocTest<EditBranchBloc, EditBranchState>(
      'emits [Initial] on reset',
      build: buildBloc,
      act: (bloc) => bloc.add(EditBranchReset()),
      expect: () => [isA<EditBranchInitial>()],
    );
  });
}
