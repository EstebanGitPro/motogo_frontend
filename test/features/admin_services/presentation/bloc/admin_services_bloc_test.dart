import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/admin_services/domain/entities/admin_service_entity.dart';
import 'package:motogo_frontend/src/features/admin_services/presentation/bloc/admin_services_event.dart';
import 'package:motogo_frontend/src/features/admin_services/presentation/bloc/admin_services_state.dart';

void main() {
  group('AdminServicesEvent', () {
    group('LoadServices', () {
      test('creates event', () {
        final event = LoadServices();
        expect(event, isA<AdminServicesEvent>());
      });

      test('props is empty', () {
        final event = LoadServices();
        expect(event.props, isEmpty);
      });
    });

    group('RefreshServices', () {
      test('creates event', () {
        final event = RefreshServices();
        expect(event, isA<AdminServicesEvent>());
      });
    });

    group('SearchServices', () {
      test('creates event with query', () {
        const event = SearchServices(query: 'aceite');
        expect(event.query, 'aceite');
        expect(event.typeFilter, isNull);
      });

      test('creates event with query and typeFilter', () {
        const event = SearchServices(
          query: 'aceite',
          typeFilter: 'Mantenimiento',
        );
        expect(event.query, 'aceite');
        expect(event.typeFilter, 'Mantenimiento');
      });

      test('supports equality', () {
        const event1 = SearchServices(query: 'aceite');
        const event2 = SearchServices(query: 'aceite');
        const event3 = SearchServices(query: 'frenos');
        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });

      test('props contains query and typeFilter', () {
        const event = SearchServices(
          query: 'aceite',
          typeFilter: 'Mantenimiento',
        );
        expect(event.props, ['aceite', 'Mantenimiento']);
      });
    });

    group('UpdateService', () {
      test('creates event with all fields', () {
        const event = UpdateService(
          serviceId: 'svc-123',
          name: 'Cambio de aceite',
          serviceType: 'Mantenimiento',
          description: 'Descripción',
          isActive: true,
        );
        expect(event.serviceId, 'svc-123');
        expect(event.name, 'Cambio de aceite');
        expect(event.serviceType, 'Mantenimiento');
        expect(event.description, 'Descripción');
        expect(event.isActive, true);
      });

      test('creates event with optional fields null', () {
        const event = UpdateService(
          serviceId: 'svc-123',
          name: 'Test',
          serviceType: 'Reparación',
        );
        expect(event.description, isNull);
        expect(event.isActive, isNull);
      });

      test('supports equality', () {
        const event1 = UpdateService(
          serviceId: 'svc-123',
          name: 'Test',
          serviceType: 'Reparación',
        );
        const event2 = UpdateService(
          serviceId: 'svc-123',
          name: 'Test',
          serviceType: 'Reparación',
        );
        expect(event1, equals(event2));
      });

      test('props contains all fields', () {
        const event = UpdateService(
          serviceId: 'svc-123',
          name: 'Test',
          serviceType: 'Rep',
          description: 'Desc',
          isActive: true,
        );
        expect(event.props, ['svc-123', 'Test', 'Rep', 'Desc', true]);
      });
    });

    group('ToggleServiceStatus', () {
      test('creates event with serviceId and activate', () {
        const event = ToggleServiceStatus(serviceId: 'svc-123', activate: true);
        expect(event.serviceId, 'svc-123');
        expect(event.activate, true);
      });

      test('supports equality', () {
        const event1 = ToggleServiceStatus(
          serviceId: 'svc-123',
          activate: true,
        );
        const event2 = ToggleServiceStatus(
          serviceId: 'svc-123',
          activate: true,
        );
        const event3 = ToggleServiceStatus(
          serviceId: 'svc-123',
          activate: false,
        );
        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });
    });
  });

  group('AdminServicesState', () {
    final testServices = [
      const AdminServiceEntity(
        id: 'svc-1',
        name: 'Cambio de aceite',
        serviceType: 'Mantenimiento',
        isActive: true,
      ),
      const AdminServiceEntity(
        id: 'svc-2',
        name: 'Ajuste de frenos',
        serviceType: 'Reparación',
        isActive: true,
      ),
    ];

    group('AdminServicesInitial', () {
      test('creates initial state', () {
        final state = AdminServicesInitial();
        expect(state, isA<AdminServicesState>());
      });

      test('props is empty', () {
        final state = AdminServicesInitial();
        expect(state.props, isEmpty);
      });
    });

    group('AdminServicesLoading', () {
      test('creates loading state', () {
        final state = AdminServicesLoading();
        expect(state, isA<AdminServicesState>());
      });
    });

    group('AdminServicesLoaded', () {
      test('creates loaded state with required fields', () {
        final state = AdminServicesLoaded(
          allServices: testServices,
          filteredServices: testServices,
        );
        expect(state.allServices.length, 2);
        expect(state.filteredServices.length, 2);
        expect(state.searchQuery, '');
        expect(state.typeFilter, isNull);
        expect(state.availableTypes, isEmpty);
      });

      test('creates loaded state with all fields', () {
        final state = AdminServicesLoaded(
          allServices: testServices,
          filteredServices: [testServices.first],
          searchQuery: 'aceite',
          typeFilter: 'Mantenimiento',
          availableTypes: const ['Mantenimiento', 'Reparación'],
        );
        expect(state.searchQuery, 'aceite');
        expect(state.typeFilter, 'Mantenimiento');
        expect(state.availableTypes.length, 2);
      });

      test('copyWith creates new state with updated values', () {
        final state = AdminServicesLoaded(
          allServices: testServices,
          filteredServices: testServices,
        );

        final newState = state.copyWith(
          searchQuery: 'frenos',
          typeFilter: 'Reparación',
        );

        expect(newState.searchQuery, 'frenos');
        expect(newState.typeFilter, 'Reparación');
        expect(newState.allServices, testServices);
      });

      test('copyWith sets typeFilter to null when not provided', () {
        final state = AdminServicesLoaded(
          allServices: testServices,
          filteredServices: testServices,
          typeFilter: 'Mantenimiento',
        );

        final newState = state.copyWith(searchQuery: 'test');
        expect(newState.typeFilter, isNull);
      });

      test('supports equality', () {
        final state1 = AdminServicesLoaded(
          allServices: testServices,
          filteredServices: testServices,
        );
        final state2 = AdminServicesLoaded(
          allServices: testServices,
          filteredServices: testServices,
        );
        expect(state1, equals(state2));
      });

      test('props contains all fields', () {
        final state = AdminServicesLoaded(
          allServices: testServices,
          filteredServices: testServices,
          searchQuery: 'q',
          typeFilter: 'T',
          availableTypes: const ['T'],
        );
        expect(state.props.length, 5);
      });
    });

    group('AdminServicesError', () {
      test('creates error state with ErrorModel', () {
        final error = ErrorModel(message: 'Error de red', errorCode: 'NET_001');
        final state = AdminServicesError(error);
        expect(state.error.message, 'Error de red');
      });

      test('supports equality', () {
        final error = ErrorModel(message: 'Error');
        final state1 = AdminServicesError(error);
        final state2 = AdminServicesError(error);
        expect(state1, equals(state2));
      });
    });

    group('AdminServicesUpdating', () {
      test('creates updating state with the updating service ID', () {
        final state = AdminServicesUpdating(
          allServices: testServices,
          filteredServices: testServices,
          updatingServiceId: 'svc-1',
        );
        expect(state.updatingServiceId, 'svc-1');
        expect(state.allServices.length, 2);
      });

      test('supports equality', () {
        final state1 = AdminServicesUpdating(
          allServices: testServices,
          filteredServices: testServices,
          updatingServiceId: 'svc-1',
        );
        final state2 = AdminServicesUpdating(
          allServices: testServices,
          filteredServices: testServices,
          updatingServiceId: 'svc-1',
        );
        expect(state1, equals(state2));
      });
    });

    group('AdminServicesUpdateSuccess', () {
      test('creates success state with message and previous state', () {
        final prevState = AdminServicesLoaded(
          allServices: testServices,
          filteredServices: testServices,
        );
        final state = AdminServicesUpdateSuccess(
          message: 'Servicio actualizado',
          previousState: prevState,
        );
        expect(state.message, 'Servicio actualizado');
        expect(state.previousState, prevState);
      });

      test('supports equality', () {
        final prevState = AdminServicesLoaded(
          allServices: testServices,
          filteredServices: testServices,
        );
        final state1 = AdminServicesUpdateSuccess(
          message: 'OK',
          previousState: prevState,
        );
        final state2 = AdminServicesUpdateSuccess(
          message: 'OK',
          previousState: prevState,
        );
        expect(state1, equals(state2));
      });
    });
  });
}
