import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/branch_detail/data/models/branch_detail_model.dart';
import 'package:motogo_frontend/src/features/branch_detail/domain/entities/branch_detail_entity.dart';

void main() {
  group('BranchDetailModel', () {
    group('fromJson', () {
      test('parses complete JSON with all fields', () {
        final json = {
          'id': 'branch-123',
          'name': 'MotoTech Garage',
          'establishment_type': 'WORKSHOP',
          'establishment_type_label': 'Taller',
          'profile_image_url': 'https://example.com/image.jpg',
          'contact_phone': '3001234567',
          'displacement_ranges': ['BAJO', 'MEDIO'],
          'location': {
            'address': 'Av. Principal 123',
            'city_name': 'Bogotá',
            'department_name': 'Cundinamarca',
            'latitude': 4.7125,
            'longitude': -74.0698,
          },
        };

        final model = BranchDetailModel.fromJson(json);

        expect(model.id, 'branch-123');
        expect(model.name, 'MotoTech Garage');
        expect(model.type, 'taller');
        expect(model.typeLabel, 'Taller');
        expect(model.profileImageUrl, 'https://example.com/image.jpg');
        expect(model.phoneNumber, '3001234567');
        expect(model.address, 'Av. Principal 123');
        expect(model.cityName, 'Bogotá');
        expect(model.departmentName, 'Cundinamarca');
        expect(model.latitude, 4.7125);
        expect(model.longitude, -74.0698);
        expect(model.displacementRanges, ['BAJO', 'MEDIO']);
      });

      test('handles missing optional fields gracefully', () {
        final json = {
          'id': 'branch-456',
          'name': 'Test Branch',
          'establishment_type': 'WORKSHOP',
        };

        final model = BranchDetailModel.fromJson(json);

        expect(model.id, 'branch-456');
        expect(model.name, 'Test Branch');
        expect(model.typeLabel, isNull);
        expect(model.profileImageUrl, isNull);
        expect(model.phoneNumber, isNull);
        expect(model.address, isNull);
        expect(model.cityName, isNull);
        expect(model.departmentName, isNull);
        expect(model.displacementRanges, isEmpty);
      });

      test('defaults id and name to empty string when null', () {
        final json = <String, dynamic>{
          'id': null,
          'name': null,
          'establishment_type': 'WORKSHOP',
        };

        final model = BranchDetailModel.fromJson(json);

        expect(model.id, '');
        expect(model.name, '');
      });
    });

    group('_mapEstablishmentType', () {
      test('maps WORKSHOP to taller', () {
        final json = {
          'id': '1',
          'name': 'Test',
          'establishment_type': 'WORKSHOP',
        };

        final model = BranchDetailModel.fromJson(json);

        expect(model.type, 'taller');
      });

      test('maps STORE to tienda', () {
        final json = {'id': '1', 'name': 'Test', 'establishment_type': 'STORE'};

        final model = BranchDetailModel.fromJson(json);

        expect(model.type, 'tienda');
      });

      test('maps WORKSHOP_STORE to taller_tienda', () {
        final json = {
          'id': '1',
          'name': 'Test',
          'establishment_type': 'WORKSHOP_STORE',
        };

        final model = BranchDetailModel.fromJson(json);

        expect(model.type, 'taller_tienda');
      });

      test('handles lowercase input', () {
        final json = {
          'id': '1',
          'name': 'Test',
          'establishment_type': 'workshop',
        };

        final model = BranchDetailModel.fromJson(json);

        expect(model.type, 'taller');
      });

      test('defaults to taller when type is null', () {
        final json = <String, dynamic>{
          'id': '1',
          'name': 'Test',
          'establishment_type': null,
        };

        final model = BranchDetailModel.fromJson(json);

        expect(model.type, 'taller');
      });

      test('returns lowercase for unknown type', () {
        final json = {
          'id': '1',
          'name': 'Test',
          'establishment_type': 'DEALER',
        };

        final model = BranchDetailModel.fromJson(json);

        expect(model.type, 'dealer');
      });
    });

    group('_parseDouble', () {
      test('handles double value', () {
        final json = {
          'id': '1',
          'name': 'Test',
          'establishment_type': 'WORKSHOP',
          'location': {'latitude': 4.7125, 'longitude': -74.0698},
        };

        final model = BranchDetailModel.fromJson(json);

        expect(model.latitude, 4.7125);
        expect(model.longitude, -74.0698);
      });

      test('handles integer value', () {
        final json = {
          'id': '1',
          'name': 'Test',
          'establishment_type': 'WORKSHOP',
          'location': {'latitude': 5, 'longitude': -74},
        };

        final model = BranchDetailModel.fromJson(json);

        expect(model.latitude, 5.0);
        expect(model.longitude, -74.0);
      });

      test('handles string value', () {
        final json = {
          'id': '1',
          'name': 'Test',
          'establishment_type': 'WORKSHOP',
          'location': {'latitude': '4.7125', 'longitude': '-74.0698'},
        };

        final model = BranchDetailModel.fromJson(json);

        expect(model.latitude, 4.7125);
        expect(model.longitude, -74.0698);
      });

      test('defaults to 0.0 when null', () {
        final json = {
          'id': '1',
          'name': 'Test',
          'establishment_type': 'WORKSHOP',
          'location': <String, dynamic>{'latitude': null, 'longitude': null},
        };

        final model = BranchDetailModel.fromJson(json);

        expect(model.latitude, 0.0);
        expect(model.longitude, 0.0);
      });

      test('defaults to 0.0 for unparseable string', () {
        final json = {
          'id': '1',
          'name': 'Test',
          'establishment_type': 'WORKSHOP',
          'location': {'latitude': 'abc', 'longitude': 'xyz'},
        };

        final model = BranchDetailModel.fromJson(json);

        expect(model.latitude, 0.0);
        expect(model.longitude, 0.0);
      });
    });

    group('_parseStringList', () {
      test('parses list of strings', () {
        final json = {
          'id': '1',
          'name': 'Test',
          'establishment_type': 'WORKSHOP',
          'displacement_ranges': ['BAJO', 'MEDIO', 'ALTO'],
        };

        final model = BranchDetailModel.fromJson(json);

        expect(model.displacementRanges, ['BAJO', 'MEDIO', 'ALTO']);
      });

      test('converts non-string list items to strings', () {
        final json = {
          'id': '1',
          'name': 'Test',
          'establishment_type': 'WORKSHOP',
          'displacement_ranges': [1, 2, 3],
        };

        final model = BranchDetailModel.fromJson(json);

        expect(model.displacementRanges, ['1', '2', '3']);
      });

      test('returns empty list when null', () {
        final json = <String, dynamic>{
          'id': '1',
          'name': 'Test',
          'establishment_type': 'WORKSHOP',
          'displacement_ranges': null,
        };

        final model = BranchDetailModel.fromJson(json);

        expect(model.displacementRanges, isEmpty);
      });

      test('returns empty list when missing', () {
        final json = {
          'id': '1',
          'name': 'Test',
          'establishment_type': 'WORKSHOP',
        };

        final model = BranchDetailModel.fromJson(json);

        expect(model.displacementRanges, isEmpty);
      });
    });

    group('toEntity', () {
      test('converts model to BranchDetailEntity with all fields', () {
        const model = BranchDetailModel(
          id: 'branch-123',
          name: 'MotoTech Garage',
          type: 'taller',
          typeLabel: 'Taller',
          profileImageUrl: 'https://example.com/image.jpg',
          address: 'Av. Principal 123',
          cityName: 'Bogotá',
          departmentName: 'Cundinamarca',
          phoneNumber: '3001234567',
          latitude: 4.7125,
          longitude: -74.0698,
          displacementRanges: ['BAJO', 'MEDIO'],
        );

        final entity = model.toEntity();

        expect(entity, isA<BranchDetailEntity>());
        expect(entity.id, 'branch-123');
        expect(entity.name, 'MotoTech Garage');
        expect(entity.type, 'taller');
        expect(entity.typeLabel, 'Taller');
        expect(entity.profileImageUrl, 'https://example.com/image.jpg');
        expect(entity.address, 'Av. Principal 123');
        expect(entity.cityName, 'Bogotá');
        expect(entity.departmentName, 'Cundinamarca');
        expect(entity.phoneNumber, '3001234567');
        expect(entity.latitude, 4.7125);
        expect(entity.longitude, -74.0698);
        expect(entity.displacementRanges, ['BAJO', 'MEDIO']);
      });
    });
  });
}
