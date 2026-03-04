import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/my_branches/presentation/bloc/my_branches_event.dart';
import 'package:motogo_frontend/src/features/my_branches/presentation/bloc/my_branches_state.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';

void main() {
  final testLocation = const BranchLocation(
    address: 'Calle 123',
    cityId: 'city-01',
    departmentId: 'dept-01',
  );

  group('MyBranchesEvent', () {
    group('LoadBranches', () {
      test('creates event', () {
        final event = LoadBranches();
        expect(event, isA<MyBranchesEvent>());
      });
    });

    group('SearchBranches', () {
      test('creates event with query', () {
        final event = SearchBranches(query: 'taller');
        expect(event.query, 'taller');
      });
    });

    group('RefreshBranches', () {
      test('creates event', () {
        final event = RefreshBranches();
        expect(event, isA<MyBranchesEvent>());
      });
    });
  });

  group('MyBranchesState', () {
    final testBranches = [
      BranchEntity(
        id: 'b-1',
        name: 'Taller Norte',
        establishmentType: 'WORKSHOP',
        location: testLocation,
      ),
      BranchEntity(
        id: 'b-2',
        name: 'Tienda Sur',
        establishmentType: 'STORE',
        location: testLocation,
      ),
    ];

    group('MyBranchesInitial', () {
      test('creates initial state', () {
        final state = MyBranchesInitial();
        expect(state, isA<MyBranchesState>());
      });
    });

    group('MyBranchesLoading', () {
      test('creates loading state', () {
        final state = MyBranchesLoading();
        expect(state, isA<MyBranchesState>());
      });
    });

    group('MyBranchesLoaded', () {
      test('creates loaded state with all fields', () {
        final state = MyBranchesLoaded(
          branches: testBranches,
          filteredBranches: testBranches,
        );
        expect(state.branches.length, 2);
        expect(state.filteredBranches.length, 2);
        expect(state.searchQuery, '');
        expect(state.franchiseNames, isEmpty);
        expect(state.branchesWithFranchise, isEmpty);
      });

      test('creates loaded state with search and franchise info', () {
        final state = MyBranchesLoaded(
          branches: testBranches,
          filteredBranches: [testBranches.first],
          searchQuery: 'taller',
          franchiseNames: {'f-1': 'MotoRed'},
          branchesWithFranchise: {'b-1'},
        );
        expect(state.searchQuery, 'taller');
        expect(state.franchiseNames['f-1'], 'MotoRed');
        expect(state.branchesWithFranchise.contains('b-1'), true);
      });

      test('copyWith creates new state', () {
        final state = MyBranchesLoaded(
          branches: testBranches,
          filteredBranches: testBranches,
          searchQuery: 'original',
        );
        final newState = state.copyWith(searchQuery: 'updated');
        expect(newState.searchQuery, 'updated');
        expect(newState.branches, testBranches);
      });

      test('copyWith preserves values when not provided', () {
        final state = MyBranchesLoaded(
          branches: testBranches,
          filteredBranches: testBranches,
          franchiseNames: {'f-1': 'MotoRed'},
          branchesWithFranchise: {'b-1'},
        );
        final newState = state.copyWith(searchQuery: 'test');
        expect(newState.franchiseNames, {'f-1': 'MotoRed'});
        expect(newState.branchesWithFranchise, {'b-1'});
      });
    });

    group('MyBranchesError', () {
      test('creates error state', () {
        final error = ErrorModel(message: 'Error de red');
        final state = MyBranchesError(error: error);
        expect(state.error.message, 'Error de red');
      });
    });
  });
}
