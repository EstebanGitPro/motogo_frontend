import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/catalogs/data/models/branch_type_model.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/branch_type_entity.dart';

void main() {
  group('BranchTypeModel', () {
    group('fromJson', () {
      test('should create BranchTypeModel from valid JSON', () {
        // Arrange
        final json = {'code': 'WORKSHOP', 'label': 'Taller'};

        // Act
        final result = BranchTypeModel.fromJson(json);

        // Assert
        expect(result.code, 'WORKSHOP');
        expect(result.label, 'Taller');
      });

      test('should handle missing code with empty string default', () {
        // Arrange
        final json = {'label': 'Taller'};

        // Act
        final result = BranchTypeModel.fromJson(json);

        // Assert
        expect(result.code, '');
        expect(result.label, 'Taller');
      });

      test('should handle missing label with empty string default', () {
        // Arrange
        final json = {'code': 'WORKSHOP'};

        // Act
        final result = BranchTypeModel.fromJson(json);

        // Assert
        expect(result.code, 'WORKSHOP');
        expect(result.label, '');
      });

      test('should handle null values with empty string defaults', () {
        // Arrange
        final json = {'code': null, 'label': null};

        // Act
        final result = BranchTypeModel.fromJson(json);

        // Assert
        expect(result.code, '');
        expect(result.label, '');
      });
    });

    group('fromJsonList', () {
      test('should parse response with types array', () {
        // Arrange
        final response = {
          'types': [
            {'code': 'WORKSHOP', 'label': 'Taller'},
            {'code': 'PARTS_STORE', 'label': 'Almacén de repuestos'},
            {'code': 'DEALER', 'label': 'Concesionario'},
          ],
        };

        // Act
        final result = BranchTypeModel.fromJsonList(response);

        // Assert
        expect(result.length, 3);
        expect(result[0].code, 'WORKSHOP');
        expect(result[0].label, 'Taller');
        expect(result[1].code, 'PARTS_STORE');
        expect(result[2].code, 'DEALER');
      });

      test('should return empty list when types is null', () {
        // Arrange
        final response = {'types': null};

        // Act
        final result = BranchTypeModel.fromJsonList(response);

        // Assert
        expect(result, isEmpty);
      });

      test('should return empty list when types key is missing', () {
        // Arrange
        final response = <String, dynamic>{};

        // Act
        final result = BranchTypeModel.fromJsonList(response);

        // Assert
        expect(result, isEmpty);
      });

      test('should return empty list for empty types array', () {
        // Arrange
        final response = {'types': []};

        // Act
        final result = BranchTypeModel.fromJsonList(response);

        // Assert
        expect(result, isEmpty);
      });
    });

    group('toEntity', () {
      test('should convert BranchTypeModel to BranchTypeEntity', () {
        // Arrange
        const model = BranchTypeModel(code: 'WORKSHOP', label: 'Taller');

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity, isA<BranchTypeEntity>());
        expect(entity.code, model.code);
        expect(entity.label, model.label);
      });
    });

    group('equality', () {
      test('two BranchTypeModels with same values should be equal', () {
        // Arrange
        const model1 = BranchTypeModel(code: 'WORKSHOP', label: 'Taller');
        const model2 = BranchTypeModel(code: 'WORKSHOP', label: 'Taller');

        // Assert
        expect(model1.code, model2.code);
        expect(model1.label, model2.label);
      });
    });
  });
}
