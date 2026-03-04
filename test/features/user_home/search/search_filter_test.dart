import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/user_home/domain/entities/branch_marker_entity.dart';
import 'package:motogo_frontend/src/features/user_home/presentation/bloc/user_home_bloc.dart';

/// Tests for the search filtering logic in UserHomeBloc state.
///
/// These tests validate the `searchResults` computed getter on `UserHomeLoaded`
/// to ensure client-side branch filtering works correctly.
void main() {
  const branch1 = BranchMarkerEntity(
    id: 'b1',
    name: 'Taller MotoSpeed',
    type: 'taller',
    latitude: 4.60971,
    longitude: -74.08175,
    address: 'Cra 7 #45-10',
    cityName: 'Bogotá',
    distanceKm: 2.3,
    serviceNames: ['Cambio de aceite', 'Sincronización'],
  );

  const branch2 = BranchMarkerEntity(
    id: 'b2',
    name: 'Tienda Repuestos Pro',
    type: 'tienda',
    latitude: 4.61,
    longitude: -74.08,
    address: 'Calle 100 #20-30',
    cityName: 'Medellín',
    distanceKm: 5.1,
    serviceNames: ['Venta de repuestos'],
  );

  const branch3 = BranchMarkerEntity(
    id: 'b3',
    name: 'Taller y Tienda Express',
    type: 'taller_tienda',
    latitude: 4.62,
    longitude: -74.09,
    address: 'Av Caracas #10-20',
    cityName: 'Bogotá',
    serviceNames: ['Cambio de aceite', 'Revisión técnica'],
  );

  const allBranches = [branch1, branch2, branch3];

  UserHomeLoaded createState({String searchQuery = ''}) {
    return UserHomeLoaded(branches: allBranches, searchQuery: searchQuery);
  }

  group('searchResults getter', () {
    test('returns empty list when searchQuery is empty', () {
      final state = createState(searchQuery: '');
      expect(state.searchResults, isEmpty);
    });

    test('filters by branch name', () {
      final state = createState(searchQuery: 'MotoSpeed');
      expect(state.searchResults, [branch1]);
    });

    test('filters by branch name case-insensitive', () {
      final state = createState(searchQuery: 'motospeed');
      expect(state.searchResults, [branch1]);
    });

    test('filters by partial branch name', () {
      final state = createState(searchQuery: 'Repuestos');
      expect(state.searchResults, [branch2]);
    });

    test('filters by address', () {
      final state = createState(searchQuery: 'Caracas');
      expect(state.searchResults, [branch3]);
    });

    test('filters by city name', () {
      final state = createState(searchQuery: 'Medellín');
      expect(state.searchResults, [branch2]);
    });

    test('filters by type label (Taller)', () {
      final state = createState(searchQuery: 'Taller');
      // branch1 (Taller), branch3 (Taller y Tienda) both match
      expect(state.searchResults, containsAll([branch1, branch3]));
    });

    test('filters by type label (Tienda)', () {
      final state = createState(searchQuery: 'Tienda');
      // branch2 (Tienda), branch3 (Taller y Tienda) both match
      expect(state.searchResults, containsAll([branch2, branch3]));
    });

    test('returns multiple matches when query is broad', () {
      final state = createState(searchQuery: 'Bogotá');
      expect(state.searchResults, [branch1, branch3]);
    });

    test('returns empty when no matches found', () {
      final state = createState(searchQuery: 'XYZ NoExiste');
      expect(state.searchResults, isEmpty);
    });

    test('filters by service name', () {
      final state = createState(searchQuery: 'Sincronización');
      expect(state.searchResults, [branch1]);
    });

    test('filters by partial service name', () {
      // "Cambio de aceite" is in branch1 and branch3
      final state = createState(searchQuery: 'aceite');
      expect(state.searchResults, [branch1, branch3]);
    });

    test('filters by service name case-insensitive', () {
      final state = createState(searchQuery: 'revisión técnica');
      expect(state.searchResults, [branch3]);
    });
  });

  group('SearchBranches event', () {
    test('has correct props', () {
      const event = SearchBranches('test query');
      expect(event.query, 'test query');
      expect(event.props, ['test query']);
    });

    test('two events with same query are equal', () {
      const event1 = SearchBranches('test');
      const event2 = SearchBranches('test');
      expect(event1, event2);
    });
  });

  group('UserHomeLoaded copyWith searchQuery', () {
    test('preserves searchQuery in copyWith', () {
      final state = createState(searchQuery: 'test');
      final copied = state.copyWith();
      expect(copied.searchQuery, 'test');
    });

    test('updates searchQuery in copyWith', () {
      final state = createState(searchQuery: 'old');
      final copied = state.copyWith(searchQuery: 'new');
      expect(copied.searchQuery, 'new');
    });

    test('searchQuery is in props for equatable', () {
      final state1 = createState(searchQuery: 'a');
      final state2 = createState(searchQuery: 'b');
      expect(state1, isNot(state2));
    });
  });
}
