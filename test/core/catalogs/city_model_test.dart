import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/catalogs/data/models/city_model.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/city_entity.dart';

void main() {
  group('CityModel', () {
    group('fromJson', () {
      test('should create CityModel from valid JSON', () {
        // Arrange
        final json = {'id': 'city-001', 'name': 'Bogotá'};

        // Act
        final result = CityModel.fromJson(json);

        // Assert
        expect(result.id, 'city-001');
        expect(result.name, 'Bogotá');
      });

      test('should throw when id is missing', () {
        // Arrange
        final json = {'name': 'Bogotá'};

        // Act & Assert
        expect(() => CityModel.fromJson(json), throwsA(isA<TypeError>()));
      });

      test('should throw when name is missing', () {
        // Arrange
        final json = {'id': 'city-001'};

        // Act & Assert
        expect(() => CityModel.fromJson(json), throwsA(isA<TypeError>()));
      });
    });

    group('fromJsonList', () {
      test('should parse HATEOAS response with cities', () {
        // Arrange
        final response = {
          'success': true,
          'data': {
            'cities': [
              {'id': 'city-001', 'name': 'Bogotá'},
              {'id': 'city-002', 'name': 'Medellín'},
              {'id': 'city-003', 'name': 'Cali'},
            ],
            '_links': [
              {
                'href': '/departments/dept-1/cities',
                'rel': 'self',
                'method': 'GET',
              },
            ],
          },
        };

        // Act
        final result = CityModel.fromJsonList(response);

        // Assert
        expect(result.length, 3);
        expect(result[0].id, 'city-001');
        expect(result[0].name, 'Bogotá');
        expect(result[1].name, 'Medellín');
        expect(result[2].name, 'Cali');
      });

      test('should return empty list when data is null', () {
        // Arrange
        final response = {'success': true, 'data': null};

        // Act
        final result = CityModel.fromJsonList(response);

        // Assert
        expect(result, isEmpty);
      });

      test('should return empty list when cities is null', () {
        // Arrange
        final response = {
          'success': true,
          'data': {'cities': null},
        };

        // Act
        final result = CityModel.fromJsonList(response);

        // Assert
        expect(result, isEmpty);
      });

      test('should return empty list when data key is missing', () {
        // Arrange
        final response = {'success': true};

        // Act
        final result = CityModel.fromJsonList(response);

        // Assert
        expect(result, isEmpty);
      });

      test('should return empty list for empty cities array', () {
        // Arrange
        final response = {
          'success': true,
          'data': {'cities': []},
        };

        // Act
        final result = CityModel.fromJsonList(response);

        // Assert
        expect(result, isEmpty);
      });
    });

    group('toEntity', () {
      test('should convert CityModel to CityEntity', () {
        // Arrange
        const model = CityModel(id: 'city-001', name: 'Bogotá');

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity, isA<CityEntity>());
        expect(entity.id, model.id);
        expect(entity.name, model.name);
      });
    });
  });
}
