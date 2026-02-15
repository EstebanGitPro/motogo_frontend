import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/branch_detail/domain/entities/branch_detail_entity.dart';

void main() {
  group('BranchDetailEntity', () {
    const entity = BranchDetailEntity(
      id: 'branch-1',
      name: 'Taller Central',
      type: 'taller',
      typeLabel: 'Taller',
      address: 'Cra 7 #45-12',
      cityName: 'Bogotá',
      departmentName: 'Cundinamarca',
      latitude: 4.624335,
      longitude: -74.063644,
      displacementRanges: ['BAJO', 'MEDIO'],
    );

    group('constructor and props', () {
      test('creates entity with required fields', () {
        expect(entity.id, 'branch-1');
        expect(entity.name, 'Taller Central');
        expect(entity.type, 'taller');
        expect(entity.latitude, 4.624335);
        expect(entity.longitude, -74.063644);
      });

      test('supports value equality', () {
        const other = BranchDetailEntity(
          id: 'branch-1',
          name: 'Taller Central',
          type: 'taller',
          typeLabel: 'Taller',
          address: 'Cra 7 #45-12',
          cityName: 'Bogotá',
          departmentName: 'Cundinamarca',
          latitude: 4.624335,
          longitude: -74.063644,
          displacementRanges: ['BAJO', 'MEDIO'],
        );

        expect(entity, equals(other));
      });

      test('defaults displacementRanges to empty list', () {
        const minimal = BranchDetailEntity(
          id: '1',
          name: 'Test',
          type: 'tienda',
          latitude: 0,
          longitude: 0,
        );
        expect(minimal.displacementRanges, isEmpty);
      });
    });

    group('isWorkshop / isStore / isWorkshopStore', () {
      test('isWorkshop returns true for taller', () {
        expect(entity.isWorkshop, isTrue);
        expect(entity.isStore, isFalse);
        expect(entity.isWorkshopStore, isFalse);
      });

      test('isStore returns true for tienda', () {
        const store = BranchDetailEntity(
          id: '2',
          name: 'Tienda',
          type: 'tienda',
          latitude: 0,
          longitude: 0,
        );
        expect(store.isStore, isTrue);
        expect(store.isWorkshop, isFalse);
      });

      test('isWorkshopStore returns true for taller_tienda', () {
        const both = BranchDetailEntity(
          id: '3',
          name: 'Mixto',
          type: 'taller_tienda',
          latitude: 0,
          longitude: 0,
        );
        expect(both.isWorkshopStore, isTrue);
      });
    });

    group('displayTypeLabel', () {
      test('returns typeLabel when provided', () {
        expect(entity.displayTypeLabel, 'Taller');
      });

      test('returns Taller for workshop without label', () {
        const noLabel = BranchDetailEntity(
          id: '1',
          name: 'T',
          type: 'taller',
          latitude: 0,
          longitude: 0,
        );
        expect(noLabel.displayTypeLabel, 'Taller');
      });

      test('returns Taller y Tienda for workshop_store without label', () {
        const noLabel = BranchDetailEntity(
          id: '1',
          name: 'T',
          type: 'taller_tienda',
          latitude: 0,
          longitude: 0,
        );
        expect(noLabel.displayTypeLabel, 'Taller y Tienda');
      });

      test('returns Tienda for store without label', () {
        const noLabel = BranchDetailEntity(
          id: '1',
          name: 'T',
          type: 'tienda',
          latitude: 0,
          longitude: 0,
        );
        expect(noLabel.displayTypeLabel, 'Tienda');
      });
    });

    group('fullAddress', () {
      test('returns address and city', () {
        expect(entity.fullAddress, 'Cra 7 #45-12, Bogotá');
      });

      test('returns only address when city is null', () {
        const noCity = BranchDetailEntity(
          id: '1',
          name: 'T',
          type: 'taller',
          address: 'Cra 7',
          latitude: 0,
          longitude: 0,
        );
        expect(noCity.fullAddress, 'Cra 7');
      });

      test('returns empty when both are null', () {
        const noAddr = BranchDetailEntity(
          id: '1',
          name: 'T',
          type: 'taller',
          latitude: 0,
          longitude: 0,
        );
        expect(noAddr.fullAddress, '');
      });
    });
  });
}
