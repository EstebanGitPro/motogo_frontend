import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/catalogs/data/models/department_model.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/department_entity.dart';

void main() {
  group('DepartmentModel', () {
    group('fromJson', () {
      test('should create DepartmentModel from valid JSON', () {
        // Arrange
        final json = {'id': 'dept-001', 'name': 'Cundinamarca'};

        // Act
        final result = DepartmentModel.fromJson(json);

        // Assert
        expect(result.id, 'dept-001');
        expect(result.name, 'Cundinamarca');
      });

      test('should throw when id is missing', () {
        // Arrange
        final json = {'name': 'Cundinamarca'};

        // Act & Assert
        expect(() => DepartmentModel.fromJson(json), throwsA(isA<TypeError>()));
      });

      test('should throw when name is missing', () {
        // Arrange
        final json = {'id': 'dept-001'};

        // Act & Assert
        expect(() => DepartmentModel.fromJson(json), throwsA(isA<TypeError>()));
      });
    });

    group('fromJsonList', () {
      test('should parse HATEOAS response with departments', () {
        // Arrange
        final response = {
          'success': true,
          'data': {
            'departments': [
              {'id': 'dept-001', 'name': 'Cundinamarca'},
              {'id': 'dept-002', 'name': 'Antioquia'},
              {'id': 'dept-003', 'name': 'Valle del Cauca'},
            ],
            '_links': [
              {'href': '/departments', 'rel': 'self', 'method': 'GET'},
            ],
          },
        };

        // Act
        final result = DepartmentModel.fromJsonList(response);

        // Assert
        expect(result.length, 3);
        expect(result[0].id, 'dept-001');
        expect(result[0].name, 'Cundinamarca');
        expect(result[1].name, 'Antioquia');
        expect(result[2].name, 'Valle del Cauca');
      });

      test('should return empty list when data is null', () {
        // Arrange
        final response = {'success': true, 'data': null};

        // Act
        final result = DepartmentModel.fromJsonList(response);

        // Assert
        expect(result, isEmpty);
      });

      test('should return empty list when departments is null', () {
        // Arrange
        final response = {
          'success': true,
          'data': {'departments': null},
        };

        // Act
        final result = DepartmentModel.fromJsonList(response);

        // Assert
        expect(result, isEmpty);
      });

      test('should return empty list when data key is missing', () {
        // Arrange
        final response = {'success': true};

        // Act
        final result = DepartmentModel.fromJsonList(response);

        // Assert
        expect(result, isEmpty);
      });

      test('should return empty list for empty departments array', () {
        // Arrange
        final response = {
          'success': true,
          'data': {'departments': []},
        };

        // Act
        final result = DepartmentModel.fromJsonList(response);

        // Assert
        expect(result, isEmpty);
      });
    });

    group('toEntity', () {
      test('should convert DepartmentModel to DepartmentEntity', () {
        // Arrange
        const model = DepartmentModel(id: 'dept-001', name: 'Cundinamarca');

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity, isA<DepartmentEntity>());
        expect(entity.id, model.id);
        expect(entity.name, model.name);
      });
    });
  });
}
