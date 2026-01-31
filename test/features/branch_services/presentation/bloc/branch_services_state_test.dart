import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/service_entity.dart';
import 'package:motogo_frontend/src/features/branch_services/domain/entities/branch_service_entity.dart';
import 'package:motogo_frontend/src/features/branch_services/presentation/bloc/branch_services_state.dart';

void main() {
  group('BranchServicesState', () {
    group('BranchServicesInitial', () {
      test('should be created', () {
        const state = BranchServicesInitial();
        expect(state, isA<BranchServicesState>());
      });

      test('props should be empty', () {
        const state = BranchServicesInitial();
        expect(state.props, isEmpty);
      });

      test('two initial states should be equal', () {
        const state1 = BranchServicesInitial();
        const state2 = BranchServicesInitial();
        expect(state1, equals(state2));
      });
    });

    group('BranchServicesLoading', () {
      test('should be created', () {
        const state = BranchServicesLoading();
        expect(state, isA<BranchServicesState>());
      });

      test('props should be empty', () {
        const state = BranchServicesLoading();
        expect(state.props, isEmpty);
      });
    });

    group('BranchServicesError', () {
      test('should create with message', () {
        const state = BranchServicesError('Error message');
        expect(state.message, 'Error message');
      });

      test('props should contain message', () {
        const state = BranchServicesError('Test error');
        expect(state.props, ['Test error']);
      });

      test('two errors with same message should be equal', () {
        const state1 = BranchServicesError('Error');
        const state2 = BranchServicesError('Error');
        expect(state1, equals(state2));
      });
    });

    group('BranchServicesLoaded', () {
      final testService = ServiceEntity(
        id: 'service-001',
        name: 'Oil Change',
        description: 'Regular oil change service',
        serviceType: 'maintenance',
      );

      final testBranchService = BranchServiceEntity(
        id: 'service-001',
        name: 'Oil Change',
        description: 'Regular oil change service',
        serviceType: 'maintenance',
        addedAt: DateTime(2024, 1, 15),
        active: true,
      );

      test('should create with required fields', () {
        final state = BranchServicesLoaded(
          allServices: [testService],
          branchServices: [testBranchService],
          displayedServices: [testService],
        );

        expect(state.allServices.length, 1);
        expect(state.branchServices.length, 1);
        expect(state.displayedServices.length, 1);
      });

      test('should have default values for optional fields', () {
        final state = BranchServicesLoaded(
          allServices: [],
          branchServices: [],
          displayedServices: [],
        );

        expect(state.filterType, isNull);
        expect(state.searchQuery, '');
        expect(state.message, isNull);
        expect(state.isSuccess, isNull);
      });

      test('associatedServiceIds should return set of branch service ids', () {
        final state = BranchServicesLoaded(
          allServices: [testService],
          branchServices: [testBranchService],
          displayedServices: [testService],
        );

        expect(state.associatedServiceIds, {'service-001'});
      });

      test('associatedServiceIds should be empty when no branch services', () {
        const state = BranchServicesLoaded(
          allServices: [],
          branchServices: [],
          displayedServices: [],
        );

        expect(state.associatedServiceIds, isEmpty);
      });

      test('copyWith should update specified fields', () {
        final original = BranchServicesLoaded(
          allServices: [testService],
          branchServices: [],
          displayedServices: [testService],
          searchQuery: '',
        );

        final updated = original.copyWith(
          searchQuery: 'oil',
          filterType: 'maintenance',
        );

        expect(updated.searchQuery, 'oil');
        expect(updated.filterType, 'maintenance');
        expect(updated.allServices, original.allServices); // unchanged
      });

      test('copyWith should preserve unspecified fields', () {
        final original = BranchServicesLoaded(
          allServices: [testService],
          branchServices: [testBranchService],
          displayedServices: [testService],
          searchQuery: 'test',
          filterType: 'maintenance',
        );

        final updated = original.copyWith(message: 'Success');

        expect(updated.allServices, original.allServices);
        expect(updated.branchServices, original.branchServices);
        expect(updated.searchQuery, original.searchQuery);
        expect(updated.filterType, original.filterType);
        expect(updated.message, 'Success');
      });

      test('copyWith with message and isSuccess', () {
        const original = BranchServicesLoaded(
          allServices: [],
          branchServices: [],
          displayedServices: [],
        );

        final updated = original.copyWith(
          message: 'Service added',
          isSuccess: true,
        );

        expect(updated.message, 'Service added');
        expect(updated.isSuccess, true);
      });

      test('props should contain all fields', () {
        final state = BranchServicesLoaded(
          allServices: [testService],
          branchServices: [testBranchService],
          displayedServices: [testService],
          filterType: 'maintenance',
          searchQuery: 'oil',
          message: 'Success',
          isSuccess: true,
        );

        expect(state.props, [
          state.allServices,
          state.branchServices,
          state.displayedServices,
          state.filterType,
          state.searchQuery,
          state.message,
          state.isSuccess,
        ]);
      });
    });
  });
}
