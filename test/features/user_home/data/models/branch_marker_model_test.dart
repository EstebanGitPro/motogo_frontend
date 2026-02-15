import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/user_home/data/models/branch_marker_model.dart';
import 'package:motogo_frontend/src/features/user_home/domain/entities/branch_marker_entity.dart';

void main() {
  group('BranchMarkerModel', () {
    group('fromJson', () {
      test('parses complete JSON with all fields', () {
        final json = {
          'id': 'branch-123',
          'name': 'Taller Moto Pro',
          'establishment_type': 'WORKSHOP',
          'establishment_type_label': 'Taller',
          'profile_image_url': 'https://example.com/image.jpg',
          'address': 'Calle 123 #45-67',
          'city_name': 'Bogotá',
          'department_name': 'Bogotá D.C.',
          'latitude': 4.7125,
          'longitude': -74.0698,
          'distance_km': 0.47,
          'rating': 4.5,
          'brands': ['Honda', 'Yamaha'],
          'displacement_ranges': ['BAJO', 'MEDIO'],
        };

        final model = BranchMarkerModel.fromJson(json);

        expect(model.id, 'branch-123');
        expect(model.name, 'Taller Moto Pro');
        expect(model.type, 'taller');
        expect(model.typeLabel, 'Taller');
        expect(model.profileImageUrl, 'https://example.com/image.jpg');
        expect(model.address, 'Calle 123 #45-67');
        expect(model.cityName, 'Bogotá');
        expect(model.departmentName, 'Bogotá D.C.');
        expect(model.latitude, 4.7125);
        expect(model.longitude, -74.0698);
        expect(model.distanceKm, 0.47);
        expect(model.rating, 4.5);
        expect(model.brands, ['Honda', 'Yamaha']);
        expect(model.displacementRanges, ['BAJO', 'MEDIO']);
      });

      test('handles missing optional fields gracefully', () {
        final json = {
          'id': 'branch-456',
          'name': 'Test Branch',
          'establishment_type': 'WORKSHOP',
          'latitude': 4.0,
          'longitude': -74.0,
        };

        final model = BranchMarkerModel.fromJson(json);

        expect(model.id, 'branch-456');
        expect(model.name, 'Test Branch');
        expect(model.type, 'taller');
        expect(model.typeLabel, isNull);
        expect(model.profileImageUrl, isNull);
        expect(model.address, isNull);
        expect(model.cityName, isNull);
        expect(model.departmentName, isNull);
        expect(model.distanceKm, isNull);
        expect(model.rating, isNull);
        expect(model.brands, isEmpty);
        expect(model.displacementRanges, isEmpty);
      });

      test('defaults id and name to empty string when null', () {
        final json = <String, dynamic>{
          'id': null,
          'name': null,
          'establishment_type': 'WORKSHOP',
          'latitude': 0,
          'longitude': 0,
        };

        final model = BranchMarkerModel.fromJson(json);

        expect(model.id, '');
        expect(model.name, '');
      });

      test('parses integer coordinates', () {
        final json = {
          'id': '1',
          'name': 'Test',
          'establishment_type': 'WORKSHOP',
          'latitude': 5,
          'longitude': -74,
        };

        final model = BranchMarkerModel.fromJson(json);

        expect(model.latitude, 5.0);
        expect(model.longitude, -74.0);
      });

      test('parses string coordinates', () {
        final json = {
          'id': '1',
          'name': 'Test',
          'establishment_type': 'WORKSHOP',
          'latitude': '4.7125',
          'longitude': '-74.0698',
        };

        final model = BranchMarkerModel.fromJson(json);

        expect(model.latitude, 4.7125);
        expect(model.longitude, -74.0698);
      });
    });

    group('_mapEstablishmentType', () {
      test('maps WORKSHOP to taller', () {
        final json = {
          'id': '1',
          'name': 'Test',
          'establishment_type': 'WORKSHOP',
          'latitude': 0.0,
          'longitude': 0.0,
        };
        expect(BranchMarkerModel.fromJson(json).type, 'taller');
      });

      test('maps STORE to tienda', () {
        final json = {
          'id': '1',
          'name': 'Test',
          'establishment_type': 'STORE',
          'latitude': 0.0,
          'longitude': 0.0,
        };
        expect(BranchMarkerModel.fromJson(json).type, 'tienda');
      });

      test('maps WORKSHOP_STORE to taller_tienda', () {
        final json = {
          'id': '1',
          'name': 'Test',
          'establishment_type': 'WORKSHOP_STORE',
          'latitude': 0.0,
          'longitude': 0.0,
        };
        expect(BranchMarkerModel.fromJson(json).type, 'taller_tienda');
      });

      test('handles lowercase input', () {
        final json = {
          'id': '1',
          'name': 'Test',
          'establishment_type': 'workshop',
          'latitude': 0.0,
          'longitude': 0.0,
        };
        expect(BranchMarkerModel.fromJson(json).type, 'taller');
      });

      test('defaults to taller when type is null', () {
        final json = <String, dynamic>{
          'id': '1',
          'name': 'Test',
          'establishment_type': null,
          'latitude': 0.0,
          'longitude': 0.0,
        };
        expect(BranchMarkerModel.fromJson(json).type, 'taller');
      });

      test('returns lowercase for unknown type', () {
        final json = {
          'id': '1',
          'name': 'Test',
          'establishment_type': 'DEALER',
          'latitude': 0.0,
          'longitude': 0.0,
        };
        expect(BranchMarkerModel.fromJson(json).type, 'dealer');
      });
    });

    group('toEntity', () {
      test('converts model to BranchMarkerEntity with all fields', () {
        const model = BranchMarkerModel(
          id: 'branch-123',
          name: 'Taller Moto Pro',
          type: 'taller',
          latitude: 4.7125,
          longitude: -74.0698,
          rating: 4.5,
          address: 'Calle 123',
          distanceKm: 2.5,
          typeLabel: 'Taller',
          profileImageUrl: 'https://example.com/img.jpg',
          cityName: 'Bogotá',
          departmentName: 'Cundinamarca',
          brands: ['Honda'],
          displacementRanges: ['BAJO'],
        );

        final entity = model.toEntity();

        expect(entity, isA<BranchMarkerEntity>());
        expect(entity.id, 'branch-123');
        expect(entity.name, 'Taller Moto Pro');
        expect(entity.type, 'taller');
        expect(entity.latitude, 4.7125);
        expect(entity.longitude, -74.0698);
        expect(entity.rating, 4.5);
        expect(entity.address, 'Calle 123');
        expect(entity.distanceKm, 2.5);
        expect(entity.typeLabel, 'Taller');
        expect(entity.profileImageUrl, 'https://example.com/img.jpg');
        expect(entity.cityName, 'Bogotá');
        expect(entity.departmentName, 'Cundinamarca');
        expect(entity.brands, ['Honda']);
        expect(entity.displacementRanges, ['BAJO']);
      });

      test('converts model with only required fields', () {
        const model = BranchMarkerModel(
          id: 'id-1',
          name: 'Test',
          type: 'tienda',
          latitude: 0,
          longitude: 0,
        );

        final entity = model.toEntity();

        expect(entity, isA<BranchMarkerEntity>());
        expect(entity.id, 'id-1');
        expect(entity.rating, isNull);
        expect(entity.address, isNull);
        expect(entity.distanceKm, isNull);
      });
    });
  });
}
