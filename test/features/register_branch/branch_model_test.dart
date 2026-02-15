import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/register_branch/data/models/branch_model.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';

void main() {
  group('BranchModel', () {
    // Sample data for tests
    const testBranchId = 'a1b2c3d4-0000-4000-8000-000000000001';
    const testCityId = 'b2c3d4e5-2222-4000-8000-000000000001';
    const testDepartmentId = 'c3d4e5f6-3333-4000-8000-000000000001';
    const testBrandIds = ['f6a7b8c9-6666-4000-8000-000000000001'];

    const testLocation = BranchLocation(
      address: 'Calle 123',
      cityId: testCityId,
      departmentId: testDepartmentId,
    );

    group('constructor', () {
      test('should create BranchModel with required fields', () {
        final model = BranchModel(
          name: 'MotoGo Centro',
          establishmentType: 'WORKSHOP',
          location: testLocation,
        );

        expect(model.name, 'MotoGo Centro');
        expect(model.establishmentType, 'WORKSHOP');
        expect(model.address, 'Calle 123');
        expect(model.cityId, testCityId);
        expect(model.departmentId, testDepartmentId);
        expect(model.status, 'ACTIVE'); // default
        expect(model.brands, isEmpty); // default
        expect(model.displacementRanges, isEmpty); // default
      });

      test('should create BranchModel with all fields', () {
        final model = BranchModel(
          id: testBranchId,
          name: 'MotoGo Centro',
          establishmentType: 'PARTS_STORE',
          franchiseId: 'franchise-123',
          profileImageUrl: 'https://example.com/image.jpg',
          status: 'INACTIVE',
          brands: testBrandIds,
          displacementRanges: const ['BAJO', 'MEDIO'],
          location: const BranchLocation(
            address: 'Calle 123 #45-67',
            cityId: testCityId,
            cityName: 'Bogotá',
            departmentId: testDepartmentId,
            departmentName: 'Cundinamarca',
          ),
        );

        expect(model.id, testBranchId);
        expect(model.profileImageUrl, 'https://example.com/image.jpg');
        expect(model.departmentName, 'Cundinamarca');
        expect(model.displacementRanges, ['BAJO', 'MEDIO']);
      });
    });

    group('fromEntity', () {
      test('should create BranchModel from BranchEntity', () {
        final entity = BranchEntity(
          name: 'Test Branch',
          establishmentType: 'WORKSHOP',
          location: testLocation,
          brands: testBrandIds,
          displacementRanges: const ['ALTO'],
        );

        final model = BranchModel.fromEntity(entity);

        expect(model.name, entity.name);
        expect(model.establishmentType, entity.establishmentType);
        expect(model.address, entity.address);
        expect(model.cityId, entity.cityId);
        expect(model.departmentId, entity.departmentId);
        expect(model.brands, entity.brands);
        expect(model.displacementRanges, ['ALTO']);
      });
    });

    group('fromJson', () {
      test('should parse JSON with flat structure', () {
        final json = {
          'id': testBranchId,
          'name': 'MotoGo Centro',
          'establishment_type': 'WORKSHOP',
          'status': 'ACTIVE',
          'brands': testBrandIds,
          'displacement_ranges': ['BAJO', 'MEDIO'],
          'address': 'Calle 123',
          'city_id': testCityId,
          'department_id': testDepartmentId,
        };

        final model = BranchModel.fromJson(json);

        expect(model.id, testBranchId);
        expect(model.name, 'MotoGo Centro');
        expect(model.establishmentType, 'WORKSHOP');
        expect(model.brands, testBrandIds);
        expect(model.departmentId, testDepartmentId);
        expect(model.displacementRanges, ['BAJO', 'MEDIO']);
      });

      test('should parse JSON with nested location object', () {
        final json = {
          'id': testBranchId,
          'name': 'MotoGo Centro',
          'establishment_type': 'WORKSHOP',
          'location': {
            'address': 'Calle 123 #45-67',
            'city_id': testCityId,
            'city_name': 'Bogotá',
            'department_id': testDepartmentId,
            'department_name': 'Cundinamarca',
          },
        };

        final model = BranchModel.fromJson(json);

        expect(model.address, 'Calle 123 #45-67');
        expect(model.cityName, 'Bogotá');
        expect(model.departmentName, 'Cundinamarca');
        expect(model.departmentId, testDepartmentId);
      });

      test('should handle null brands', () {
        final json = {
          'name': 'Test',
          'establishment_type': 'WORKSHOP',
          'address': 'Test',
          'city_id': testCityId,
          'department_id': testDepartmentId,
          'brands': null,
        };

        final model = BranchModel.fromJson(json);

        expect(model.brands, isEmpty);
      });
    });

    group('toJson', () {
      test(
        'should serialize to JSON with nested location per API contract',
        () {
          final model = BranchModel(
            name: 'MotoGo Centro',
            establishmentType: 'WORKSHOP',
            brands: testBrandIds,
            displacementRanges: const ['BAJO', 'ALTO'],
            location: const BranchLocation(
              address: 'Calle 123',
              cityId: testCityId,
              cityName: 'Bogotá',
              departmentId: testDepartmentId,
              departmentName: 'Cundinamarca',
            ),
          );

          final json = model.toJson();

          expect(json['name'], 'MotoGo Centro');
          expect(json['establishment_type'], 'WORKSHOP');
          expect(json['brands'], testBrandIds);
          expect(json['displacement_ranges'], ['BAJO', 'ALTO']);
          expect(json['location'], isA<Map>());
          expect(json['location']['department_id'], testDepartmentId);
          expect(json['location']['city_id'], testCityId);
          expect(json['location']['address'], 'Calle 123');
          // Names are included for geocoding assistance
          expect(json['location']['city_name'], 'Bogotá');
          expect(json['location']['department_name'], 'Cundinamarca');
          // Coordinates should NOT be present (backend handles via geocoding)
          expect(json['location'].containsKey('latitude'), isFalse);
          expect(json['location'].containsKey('longitude'), isFalse);
        },
      );

      test('should omit optional fields when null or empty', () {
        final model = BranchModel(
          name: 'Test',
          establishmentType: 'WORKSHOP',
          location: testLocation,
        );

        final json = model.toJson();

        expect(json.containsKey('franchise_id'), isFalse);
        expect(json.containsKey('profile_image_url'), isFalse);
        expect(json.containsKey('brands'), isFalse);
        expect(json.containsKey('displacement_ranges'), isFalse);
      });

      test('should include profileImageUrl when set', () {
        final model = BranchModel(
          name: 'Test',
          establishmentType: 'WORKSHOP',
          location: testLocation,
          profileImageUrl: 'https://example.com/image.jpg',
        );

        final json = model.toJson();

        expect(json['profile_image_url'], 'https://example.com/image.jpg');
      });
    });

    group('toEntity', () {
      test('should convert to BranchEntity with all fields', () {
        final model = BranchModel(
          id: testBranchId,
          name: 'Test Branch',
          establishmentType: 'WORKSHOP',
          brands: testBrandIds,
          displacementRanges: const ['MEDIO'],
          location: const BranchLocation(
            address: 'Test Address',
            cityId: testCityId,
            cityName: 'Bogotá',
            departmentId: testDepartmentId,
          ),
        );

        final entity = model.toEntity();

        expect(entity, isA<BranchEntity>());
        expect(entity.id, model.id);
        expect(entity.name, model.name);
        expect(entity.cityName, model.cityName);
        expect(entity.departmentId, model.departmentId);
        expect(entity.brands, model.brands);
        expect(entity.displacementRanges, ['MEDIO']);
      });
    });

    group('_parseStringList helper', () {
      test('should handle list of strings for brands', () {
        final json = {
          'name': 'Test',
          'establishment_type': 'WORKSHOP',
          'address': 'Test',
          'city_id': testCityId,
          'department_id': testDepartmentId,
          'brands': ['brand-1', 'brand-2'],
        };

        final model = BranchModel.fromJson(json);

        expect(model.brands, ['brand-1', 'brand-2']);
      });

      test('should convert non-string list items to strings', () {
        final json = {
          'name': 'Test',
          'establishment_type': 'WORKSHOP',
          'address': 'Test',
          'city_id': testCityId,
          'department_id': testDepartmentId,
          'brands': [1, 2, 3],
        };

        final model = BranchModel.fromJson(json);

        expect(model.brands, ['1', '2', '3']);
      });

      test('should parse displacement_ranges as string list', () {
        final json = {
          'name': 'Test',
          'establishment_type': 'WORKSHOP',
          'address': 'Test',
          'city_id': testCityId,
          'department_id': testDepartmentId,
          'displacement_ranges': ['BAJO', 'MEDIO', 'ALTO'],
        };

        final model = BranchModel.fromJson(json);

        expect(model.displacementRanges, ['BAJO', 'MEDIO', 'ALTO']);
      });

      test('should handle null displacement_ranges', () {
        final json = {
          'name': 'Test',
          'establishment_type': 'WORKSHOP',
          'address': 'Test',
          'city_id': testCityId,
          'department_id': testDepartmentId,
          'displacement_ranges': null,
        };

        final model = BranchModel.fromJson(json);

        expect(model.displacementRanges, isEmpty);
      });
    });
  });
}
