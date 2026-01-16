import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/service_entity.dart';
import 'package:motogo_frontend/src/features/branch_services/domain/entities/branch_service_entity.dart';
import 'package:motogo_frontend/src/features/branch_services/presentation/bloc/branch_services_event.dart';
import 'package:motogo_frontend/src/features/branch_services/presentation/bloc/branch_services_state.dart';

void main() {
  group('BranchServicesEvent', () {
    group('LoadBranchServices', () {
      test('creates event with branchId', () {
        const event = LoadBranchServices('branch-123');

        expect(event.branchId, 'branch-123');
      });

      test('supports equality', () {
        const event1 = LoadBranchServices('branch-123');
        const event2 = LoadBranchServices('branch-123');
        const event3 = LoadBranchServices('branch-456');

        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });
    });

    group('FilterServicesByType', () {
      test('creates event with serviceType', () {
        const event = FilterServicesByType('Mantenimiento');

        expect(event.serviceType, 'Mantenimiento');
      });

      test('supports null serviceType for all filter', () {
        const event = FilterServicesByType(null);

        expect(event.serviceType, isNull);
      });
    });

    group('SearchServices', () {
      test('creates event with query', () {
        const event = SearchServices('aceite');

        expect(event.query, 'aceite');
      });
    });

    group('ToggleServiceAssociation', () {
      test('creates event for association', () {
        const event = ToggleServiceAssociation(
          serviceId: 'service-123',
          associate: true,
        );

        expect(event.serviceId, 'service-123');
        expect(event.associate, true);
      });

      test('creates event for dissociation', () {
        const event = ToggleServiceAssociation(
          serviceId: 'service-123',
          associate: false,
        );

        expect(event.associate, false);
      });

      test('supports equality', () {
        const event1 = ToggleServiceAssociation(
          serviceId: 'service-123',
          associate: true,
        );
        const event2 = ToggleServiceAssociation(
          serviceId: 'service-123',
          associate: true,
        );

        expect(event1, equals(event2));
      });
    });
  });

  group('BranchServicesState', () {
    group('BranchServicesInitial', () {
      test('creates initial state', () {
        const state = BranchServicesInitial();

        expect(state, isA<BranchServicesState>());
      });
    });

    group('BranchServicesLoading', () {
      test('creates loading state', () {
        const state = BranchServicesLoading();

        expect(state, isA<BranchServicesState>());
      });
    });

    group('BranchServicesLoaded', () {
      final testServices = [
        ServiceEntity(
          id: 'service-1',
          name: 'Cambio de aceite',
          description: 'Test',
          serviceType: 'Mantenimiento',
        ),
        ServiceEntity(
          id: 'service-2',
          name: 'Ajuste de frenos',
          description: 'Test',
          serviceType: 'Reparación',
        ),
      ];

      final testBranchServices = [
        BranchServiceEntity(
          id: 'service-1',
          name: 'Cambio de aceite',
          description: 'Test',
          serviceType: 'Mantenimiento',
          addedAt: DateTime.now(),
          active: true,
        ),
      ];

      test('creates loaded state with services', () {
        final state = BranchServicesLoaded(
          allServices: testServices,
          branchServices: testBranchServices,
          displayedServices: testServices,
        );

        expect(state.allServices.length, 2);
        expect(state.branchServices.length, 1);
        expect(state.displayedServices.length, 2);
      });

      test('associatedServiceIds returns correct set', () {
        final state = BranchServicesLoaded(
          allServices: testServices,
          branchServices: testBranchServices,
          displayedServices: testServices,
        );

        expect(state.associatedServiceIds, {'service-1'});
      });

      test('copyWith creates new state with updated values', () {
        final state = BranchServicesLoaded(
          allServices: testServices,
          branchServices: testBranchServices,
          displayedServices: testServices,
        );

        final newState = state.copyWith(
          filterType: 'Mantenimiento',
          searchQuery: 'aceite',
        );

        expect(newState.filterType, 'Mantenimiento');
        expect(newState.searchQuery, 'aceite');
        expect(newState.allServices, state.allServices);
      });

      test('copyWith supports message and isSuccess', () {
        final state = BranchServicesLoaded(
          allServices: testServices,
          branchServices: testBranchServices,
          displayedServices: testServices,
        );

        final newState = state.copyWith(
          message: 'Servicio asociado exitosamente',
          isSuccess: true,
        );

        expect(newState.message, 'Servicio asociado exitosamente');
        expect(newState.isSuccess, true);
      });

      test('message is reset when copyWith is called without message', () {
        final state = BranchServicesLoaded(
          allServices: testServices,
          branchServices: testBranchServices,
          displayedServices: testServices,
          message: 'Old message',
          isSuccess: true,
        );

        final newState = state.copyWith(filterType: 'Test');

        // Note: copyWith sets message to null when not provided
        expect(newState.message, isNull);
      });
    });

    group('BranchServicesError', () {
      test('creates error state with message', () {
        const state = BranchServicesError('Error de conexión');

        expect(state.message, 'Error de conexión');
      });

      test('supports equality', () {
        const state1 = BranchServicesError('Error');
        const state2 = BranchServicesError('Error');

        expect(state1, equals(state2));
      });
    });
  });
}
