import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/manage_franchise/presentation/bloc/manage_franchise_event.dart';
import 'package:motogo_frontend/src/features/manage_franchise/presentation/bloc/manage_franchise_state.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';
import 'package:motogo_frontend/src/features/register_franchise/domain/entities/franchise_entity.dart';

void main() {
  group('ManageFranchiseEvent', () {
    group('LoadFranchise', () {
      test('creates event with franchiseId', () {
        const event = LoadFranchise('franchise-123');
        expect(event.franchiseId, 'franchise-123');
      });

      test('supports equality', () {
        const event1 = LoadFranchise('franchise-123');
        const event2 = LoadFranchise('franchise-123');
        const event3 = LoadFranchise('franchise-456');
        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });

      test('props contains franchiseId', () {
        const event = LoadFranchise('franchise-123');
        expect(event.props, ['franchise-123']);
      });
    });

    group('UnlinkBranchEvent', () {
      test('creates event with branchId', () {
        const event = UnlinkBranchEvent('branch-123');
        expect(event.branchId, 'branch-123');
      });

      test('supports equality', () {
        const event1 = UnlinkBranchEvent('branch-123');
        const event2 = UnlinkBranchEvent('branch-123');
        expect(event1, equals(event2));
      });
    });

    group('LinkBranchEvent', () {
      test('creates event with branchId', () {
        const event = LinkBranchEvent('branch-123');
        expect(event.branchId, 'branch-123');
      });

      test('supports equality', () {
        const event1 = LinkBranchEvent('branch-123');
        const event2 = LinkBranchEvent('branch-123');
        expect(event1, equals(event2));
      });
    });

    group('UpdateFranchiseEvent', () {
      test('creates event with required name', () {
        const event = UpdateFranchiseEvent(name: 'MotoRed');
        expect(event.name, 'MotoRed');
        expect(event.description, isNull);
      });

      test('creates event with name and description', () {
        const event = UpdateFranchiseEvent(
          name: 'MotoRed',
          description: 'Red de motos',
        );
        expect(event.name, 'MotoRed');
        expect(event.description, 'Red de motos');
      });

      test('supports equality', () {
        const event1 = UpdateFranchiseEvent(name: 'MotoRed');
        const event2 = UpdateFranchiseEvent(name: 'MotoRed');
        const event3 = UpdateFranchiseEvent(name: 'OtherRed');
        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });

      test('props contains name and description', () {
        const event = UpdateFranchiseEvent(
          name: 'MotoRed',
          description: 'Desc',
        );
        expect(event.props, ['MotoRed', 'Desc']);
      });
    });

    group('DeleteFranchiseEvent', () {
      test('creates event', () {
        const event = DeleteFranchiseEvent();
        expect(event, isA<ManageFranchiseEvent>());
      });

      test('props is empty', () {
        const event = DeleteFranchiseEvent();
        expect(event.props, isEmpty);
      });
    });
  });

  group('ManageFranchiseState', () {
    const testFranchise = FranchiseEntity(id: 'franchise-1', name: 'MotoRed');

    final testLinkedBranches = [
      BranchEntity(
        id: 'b-1',
        name: 'Sucursal Norte',
        establishmentType: 'WORKSHOP',
        location: const BranchLocation(
          address: 'Calle 1',
          cityId: 'c-1',
          departmentId: 'd-1',
        ),
      ),
      BranchEntity(
        id: 'b-2',
        name: 'Sucursal Sur',
        establishmentType: 'STORE',
        location: const BranchLocation(
          address: 'Calle 2',
          cityId: 'c-2',
          departmentId: 'd-2',
        ),
      ),
    ];

    final testAvailableBranches = [
      BranchEntity(
        id: 'b-3',
        name: 'Sucursal Este',
        establishmentType: 'WORKSHOP',
        location: const BranchLocation(
          address: 'Calle 3',
          cityId: 'c-3',
          departmentId: 'd-3',
        ),
      ),
    ];

    group('ManageFranchiseLoading', () {
      test('creates loading state', () {
        const state = ManageFranchiseLoading();
        expect(state, isA<ManageFranchiseState>());
      });

      test('props is empty', () {
        const state = ManageFranchiseLoading();
        expect(state.props, isEmpty);
      });
    });

    group('ManageFranchiseLoaded', () {
      test('creates loaded state with all fields', () {
        final state = ManageFranchiseLoaded(
          franchise: testFranchise,
          linkedBranches: testLinkedBranches,
          availableBranches: testAvailableBranches,
        );
        expect(state.franchise, testFranchise);
        expect(state.linkedBranches.length, 2);
        expect(state.availableBranches.length, 1);
      });

      test('supports equality', () {
        final state1 = ManageFranchiseLoaded(
          franchise: testFranchise,
          linkedBranches: testLinkedBranches,
          availableBranches: testAvailableBranches,
        );
        final state2 = ManageFranchiseLoaded(
          franchise: testFranchise,
          linkedBranches: testLinkedBranches,
          availableBranches: testAvailableBranches,
        );
        expect(state1, equals(state2));
      });

      test('props contains all fields', () {
        final state = ManageFranchiseLoaded(
          franchise: testFranchise,
          linkedBranches: testLinkedBranches,
          availableBranches: testAvailableBranches,
        );
        expect(state.props.length, 3);
      });
    });

    group('ManageFranchiseError', () {
      test('creates error state with message', () {
        const state = ManageFranchiseError('Error de red');
        expect(state.message, 'Error de red');
      });

      test('supports equality', () {
        const state1 = ManageFranchiseError('Error');
        const state2 = ManageFranchiseError('Error');
        expect(state1, equals(state2));
      });
    });

    group('ManageFranchiseDeleted', () {
      test('creates deleted state with message', () {
        const state = ManageFranchiseDeleted('Franquicia eliminada');
        expect(state.message, 'Franquicia eliminada');
      });

      test('supports equality', () {
        const state1 = ManageFranchiseDeleted('msg');
        const state2 = ManageFranchiseDeleted('msg');
        expect(state1, equals(state2));
      });
    });

    group('ManageFranchiseUpdated', () {
      test('creates updated state with franchise and message', () {
        const state = ManageFranchiseUpdated(
          franchise: testFranchise,
          message: 'Franquicia actualizada',
        );
        expect(state.franchise, testFranchise);
        expect(state.message, 'Franquicia actualizada');
      });

      test('supports equality', () {
        const state1 = ManageFranchiseUpdated(
          franchise: testFranchise,
          message: 'msg',
        );
        const state2 = ManageFranchiseUpdated(
          franchise: testFranchise,
          message: 'msg',
        );
        expect(state1, equals(state2));
      });

      test('props contains franchise and message', () {
        const state = ManageFranchiseUpdated(
          franchise: testFranchise,
          message: 'msg',
        );
        expect(state.props.length, 2);
      });
    });
  });
}
