import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/catalogs/data/models/brand_model.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/brand_entity.dart';

void main() {
  group('BrandModel', () {
    group('fromJson', () {
      test('should create BrandModel from valid JSON', () {
        // Arrange
        final json = {
          'id': 'f6a7b8c9-6666-4000-8000-000000000001',
          'name': 'Honda',
        };

        // Act
        final result = BrandModel.fromJson(json);

        // Assert
        expect(result.id, 'f6a7b8c9-6666-4000-8000-000000000001');
        expect(result.name, 'Honda');
      });

      test('should throw when id is missing', () {
        // Arrange
        final json = {'name': 'Honda'};

        // Act & Assert
        expect(() => BrandModel.fromJson(json), throwsA(isA<TypeError>()));
      });

      test('should throw when name is missing', () {
        // Arrange
        final json = {'id': 'f6a7b8c9-6666-4000-8000-000000000001'};

        // Act & Assert
        expect(() => BrandModel.fromJson(json), throwsA(isA<TypeError>()));
      });
    });

    group('fromJsonList', () {
      test('should parse HATEOAS response with brands', () {
        // Arrange - Simulates actual API response
        final response = {
          'success': true,
          'code': 'MOD_B_BRD_EXI_00001',
          'message': 'Lista de marcas obtenida exitosamente.',
          'data': {
            'brands': [
              {'id': 'f6a7b8c9-6666-4000-8000-000000000001', 'name': 'Honda'},
              {'id': 'f6a7b8c9-6666-4000-8000-000000000002', 'name': 'Yamaha'},
              {'id': 'f6a7b8c9-6666-4000-8000-000000000003', 'name': 'Suzuki'},
            ],
            '_links': [
              {'href': '/brands', 'rel': 'self', 'method': 'GET'},
            ],
          },
        };

        // Act
        final result = BrandModel.fromJsonList(response);

        // Assert
        expect(result.length, 3);
        expect(result[0].id, 'f6a7b8c9-6666-4000-8000-000000000001');
        expect(result[0].name, 'Honda');
        expect(result[1].name, 'Yamaha');
        expect(result[2].name, 'Suzuki');
      });

      test('should return empty list when data is null', () {
        // Arrange
        final response = {'success': true, 'data': null};

        // Act
        final result = BrandModel.fromJsonList(response);

        // Assert
        expect(result, isEmpty);
      });

      test('should return empty list when brands is null', () {
        // Arrange
        final response = {
          'success': true,
          'data': {'brands': null},
        };

        // Act
        final result = BrandModel.fromJsonList(response);

        // Assert
        expect(result, isEmpty);
      });

      test('should return empty list when data key is missing', () {
        // Arrange
        final response = {'success': true};

        // Act
        final result = BrandModel.fromJsonList(response);

        // Assert
        expect(result, isEmpty);
      });

      test('should return empty list for empty brands array', () {
        // Arrange
        final response = {
          'success': true,
          'data': {'brands': []},
        };

        // Act
        final result = BrandModel.fromJsonList(response);

        // Assert
        expect(result, isEmpty);
      });
    });

    group('toEntity', () {
      test('should convert BrandModel to BrandEntity', () {
        // Arrange
        const model = BrandModel(
          id: 'f6a7b8c9-6666-4000-8000-000000000001',
          name: 'Honda',
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity, isA<BrandEntity>());
        expect(entity.id, model.id);
        expect(entity.name, model.name);
      });
    });

    group('equality', () {
      test('two BrandModels with same values should be equal', () {
        // Arrange
        const model1 = BrandModel(
          id: 'f6a7b8c9-6666-4000-8000-000000000001',
          name: 'Honda',
        );
        const model2 = BrandModel(
          id: 'f6a7b8c9-6666-4000-8000-000000000001',
          name: 'Honda',
        );

        // Assert
        expect(model1, equals(model2));
        expect(model1.hashCode, equals(model2.hashCode));
      });

      test('two BrandModels with different ids should not be equal', () {
        // Arrange
        const model1 = BrandModel(
          id: 'f6a7b8c9-6666-4000-8000-000000000001',
          name: 'Honda',
        );
        const model2 = BrandModel(
          id: 'f6a7b8c9-6666-4000-8000-000000000002',
          name: 'Honda',
        );

        // Assert
        expect(model1, isNot(equals(model2)));
      });
    });
  });
}
