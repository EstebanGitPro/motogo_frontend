import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/branch_services/presentation/bloc/branch_services_event.dart';

void main() {
  group('BranchServicesEvent', () {
    group('LoadBranchServices', () {
      test('should create with branchId', () {
        // Arrange & Act
        const event = LoadBranchServices('branch-001');

        // Assert
        expect(event.branchId, 'branch-001');
      });

      test('props should contain branchId', () {
        const event = LoadBranchServices('branch-002');
        expect(event.props, [event.branchId]);
      });

      test('two events with same branchId should be equal', () {
        const event1 = LoadBranchServices('branch-001');
        const event2 = LoadBranchServices('branch-001');
        expect(event1, equals(event2));
      });

      test('two events with different branchId should not be equal', () {
        const event1 = LoadBranchServices('branch-001');
        const event2 = LoadBranchServices('branch-002');
        expect(event1, isNot(equals(event2)));
      });
    });

    group('FilterServicesByType', () {
      test('should create with serviceType', () {
        const event = FilterServicesByType('maintenance');
        expect(event.serviceType, 'maintenance');
      });

      test('should accept null serviceType (show all)', () {
        const event = FilterServicesByType(null);
        expect(event.serviceType, isNull);
      });

      test('props should contain serviceType', () {
        const event = FilterServicesByType('repair');
        expect(event.props, [event.serviceType]);
      });

      test('two events with same type should be equal', () {
        const event1 = FilterServicesByType('maintenance');
        const event2 = FilterServicesByType('maintenance');
        expect(event1, equals(event2));
      });
    });

    group('SearchServices', () {
      test('should create with query', () {
        const event = SearchServices('oil change');
        expect(event.query, 'oil change');
      });

      test('should accept empty query', () {
        const event = SearchServices('');
        expect(event.query, '');
      });

      test('props should contain query', () {
        const event = SearchServices('brake service');
        expect(event.props, [event.query]);
      });

      test('two events with same query should be equal', () {
        const event1 = SearchServices('oil');
        const event2 = SearchServices('oil');
        expect(event1, equals(event2));
      });
    });

    group('ToggleServiceAssociation', () {
      test('should create with serviceId and associate true', () {
        const event = ToggleServiceAssociation(
          serviceId: 'service-001',
          associate: true,
        );
        expect(event.serviceId, 'service-001');
        expect(event.associate, true);
      });

      test('should create with associate false', () {
        const event = ToggleServiceAssociation(
          serviceId: 'service-002',
          associate: false,
        );
        expect(event.associate, false);
      });

      test('props should contain serviceId and associate', () {
        const event = ToggleServiceAssociation(
          serviceId: 'service-003',
          associate: true,
        );
        expect(event.props, [event.serviceId, event.associate]);
      });

      test('two events with same values should be equal', () {
        const event1 = ToggleServiceAssociation(
          serviceId: 'service-001',
          associate: true,
        );
        const event2 = ToggleServiceAssociation(
          serviceId: 'service-001',
          associate: true,
        );
        expect(event1, equals(event2));
      });

      test('events with different associate should not be equal', () {
        const event1 = ToggleServiceAssociation(
          serviceId: 'service-001',
          associate: true,
        );
        const event2 = ToggleServiceAssociation(
          serviceId: 'service-001',
          associate: false,
        );
        expect(event1, isNot(equals(event2)));
      });
    });
  });
}
