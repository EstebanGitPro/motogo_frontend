import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/edit_branch/presentation/bloc/edit_branch_event.dart';
import 'package:motogo_frontend/src/features/edit_branch/presentation/bloc/edit_branch_state.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';

void main() {
  final testLocation = const BranchLocation(
    address: 'Calle 123',
    cityId: 'city-01',
    departmentId: 'dept-01',
  );

  group('EditBranchEvent', () {
    group('EditBranchSubmitted', () {
      test('creates event with branchId and branch', () {
        final branch = BranchEntity(
          id: 'b-1',
          name: 'Test Branch',
          establishmentType: 'WORKSHOP',
          location: testLocation,
        );
        final event = EditBranchSubmitted(branchId: 'b-1', branch: branch);
        expect(event.branchId, 'b-1');
        expect(event.branch.name, 'Test Branch');
      });
    });

    group('EditBranchReset', () {
      test('creates event', () {
        final event = EditBranchReset();
        expect(event, isA<EditBranchEvent>());
      });
    });
  });

  group('EditBranchState', () {
    group('EditBranchInitial', () {
      test('creates initial state', () {
        final state = EditBranchInitial();
        expect(state, isA<EditBranchState>());
      });
    });

    group('EditBranchLoading', () {
      test('creates loading state', () {
        final state = EditBranchLoading();
        expect(state, isA<EditBranchState>());
      });
    });

    group('EditBranchSuccess', () {
      test('creates success state with updated branch and message', () {
        final branch = BranchEntity(
          id: 'b-1',
          name: 'Updated Branch',
          establishmentType: 'STORE',
          location: testLocation,
        );
        final state = EditBranchSuccess(
          updatedBranch: branch,
          message: 'Sucursal actualizada',
        );
        expect(state.updatedBranch.name, 'Updated Branch');
        expect(state.message, 'Sucursal actualizada');
      });
    });

    group('EditBranchFailure', () {
      test('creates failure state with ErrorModel', () {
        final error = ErrorModel(
          message: 'Error al actualizar',
          errorCode: 'EDIT_001',
        );
        final state = EditBranchFailure(error: error);
        expect(state.error.message, 'Error al actualizar');
        expect(state.error.errorCode, 'EDIT_001');
      });
    });
  });
}
