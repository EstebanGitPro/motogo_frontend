import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/user_home/domain/entities/branch_marker_entity.dart';

void main() {
  group('BranchMarkerEntity', () {
    group('constructor', () {
      test('should create instance with required fields', () {
        // Act
        const entity = BranchMarkerEntity(
          id: 'branch-123',
          name: 'Test Workshop',
          type: 'taller',
          latitude: 4.6509,
          longitude: -74.0549,
        );

        // Assert
        expect(entity.id, 'branch-123');
        expect(entity.name, 'Test Workshop');
        expect(entity.type, 'taller');
        expect(entity.latitude, 4.6509);
        expect(entity.longitude, -74.0549);
      });

      test('should create instance with all optional fields', () {
        // Act
        const entity = BranchMarkerEntity(
          id: 'branch-123',
          name: 'Full Workshop',
          type: 'taller',
          latitude: 4.6509,
          longitude: -74.0549,
          rating: 4.5,
          address: 'Calle 123',
          distanceKm: 2.5,
          typeLabel: 'Taller Oficial',
          profileImageUrl: 'https://example.com/img.jpg',
          cityName: 'Bogotá',
          departmentName: 'Cundinamarca',
        );

        // Assert
        expect(entity.rating, 4.5);
        expect(entity.address, 'Calle 123');
        expect(entity.distanceKm, 2.5);
        expect(entity.typeLabel, 'Taller Oficial');
        expect(entity.profileImageUrl, 'https://example.com/img.jpg');
        expect(entity.cityName, 'Bogotá');
        expect(entity.departmentName, 'Cundinamarca');
      });
    });

    group('isWorkshop', () {
      test('should return true when type is taller', () {
        const entity = BranchMarkerEntity(
          id: 'id',
          name: 'name',
          type: 'taller',
          latitude: 0,
          longitude: 0,
        );
        expect(entity.isWorkshop, isTrue);
      });

      test('should return false when type is tienda', () {
        const entity = BranchMarkerEntity(
          id: 'id',
          name: 'name',
          type: 'tienda',
          latitude: 0,
          longitude: 0,
        );
        expect(entity.isWorkshop, isFalse);
      });
    });

    group('isStore', () {
      test('should return true when type is tienda', () {
        const entity = BranchMarkerEntity(
          id: 'id',
          name: 'name',
          type: 'tienda',
          latitude: 0,
          longitude: 0,
        );
        expect(entity.isStore, isTrue);
      });

      test('should return false when type is taller', () {
        const entity = BranchMarkerEntity(
          id: 'id',
          name: 'name',
          type: 'taller',
          latitude: 0,
          longitude: 0,
        );
        expect(entity.isStore, isFalse);
      });
    });

    group('formattedDistance', () {
      test('should return empty string when distanceKm is null', () {
        const entity = BranchMarkerEntity(
          id: 'id',
          name: 'name',
          type: 'taller',
          latitude: 0,
          longitude: 0,
        );
        expect(entity.formattedDistance, '');
      });

      test('should format distance in meters when less than 1 km', () {
        const entity = BranchMarkerEntity(
          id: 'id',
          name: 'name',
          type: 'taller',
          latitude: 0,
          longitude: 0,
          distanceKm: 0.5,
        );
        expect(entity.formattedDistance, '500 m');
      });

      test('should format distance in km when 1 km or more', () {
        const entity = BranchMarkerEntity(
          id: 'id',
          name: 'name',
          type: 'taller',
          latitude: 0,
          longitude: 0,
          distanceKm: 2.5,
        );
        expect(entity.formattedDistance, '2.5 km');
      });
    });

    group('displayTypeLabel', () {
      test('should return typeLabel when provided', () {
        const entity = BranchMarkerEntity(
          id: 'id',
          name: 'name',
          type: 'taller',
          latitude: 0,
          longitude: 0,
          typeLabel: 'Custom Label',
        );
        expect(entity.displayTypeLabel, 'Custom Label');
      });

      test('should return Taller when isWorkshop and no typeLabel', () {
        const entity = BranchMarkerEntity(
          id: 'id',
          name: 'name',
          type: 'taller',
          latitude: 0,
          longitude: 0,
        );
        expect(entity.displayTypeLabel, 'Taller');
      });

      test('should return Tienda when isStore and no typeLabel', () {
        const entity = BranchMarkerEntity(
          id: 'id',
          name: 'name',
          type: 'tienda',
          latitude: 0,
          longitude: 0,
        );
        expect(entity.displayTypeLabel, 'Tienda');
      });
    });

    group('Equatable', () {
      test('props should include all fields', () {
        const entity = BranchMarkerEntity(
          id: 'id',
          name: 'name',
          type: 'taller',
          latitude: 4.65,
          longitude: -74.05,
          rating: 4.5,
          address: 'addr',
        );
        expect(entity.props.length, 12);
        expect(entity.props, contains('id'));
        expect(entity.props, contains('taller'));
      });
    });
  });
}
