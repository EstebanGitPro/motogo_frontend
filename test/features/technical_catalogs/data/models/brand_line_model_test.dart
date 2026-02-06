import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/data/models/brand_line_model.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/entities/brand_line_entity.dart';

void main() {
  group('BrandLineModel', () {
    group('constructor', () {
      test('should create instance with required fields', () {
        // Act
        const model = BrandLineModel(brandName: 'Honda', model: 'CBR 600RR');

        // Assert
        expect(model.brandName, 'Honda');
        expect(model.model, 'CBR 600RR');
      });

      test('should extend BrandLineEntity', () {
        // Act
        const model = BrandLineModel(brandName: 'Honda', model: 'CBR');

        // Assert
        expect(model, isA<BrandLineEntity>());
      });
    });

    group('fromJson', () {
      test('should parse complete JSON correctly', () {
        // Arrange
        final json = {'brand_name': 'Yamaha', 'model': 'YZF-R1'};

        // Act
        final model = BrandLineModel.fromJson(json);

        // Assert
        expect(model.brandName, 'Yamaha');
        expect(model.model, 'YZF-R1');
      });

      test('should handle missing brand_name with empty string', () {
        // Arrange
        final json = {'model': 'CBR 600'};

        // Act
        final model = BrandLineModel.fromJson(json);

        // Assert
        expect(model.brandName, '');
        expect(model.model, 'CBR 600');
      });

      test('should handle missing model with empty string', () {
        // Arrange
        final json = {'brand_name': 'Honda'};

        // Act
        final model = BrandLineModel.fromJson(json);

        // Assert
        expect(model.brandName, 'Honda');
        expect(model.model, '');
      });

      test('should handle empty JSON', () {
        // Arrange
        final json = <String, dynamic>{};

        // Act
        final model = BrandLineModel.fromJson(json);

        // Assert
        expect(model.brandName, '');
        expect(model.model, '');
      });
    });

    group('fromJsonList', () {
      test('should parse HATEOAS response with lines', () {
        // Arrange
        final response = {
          'success': true,
          'data': {
            'lines': [
              {'brand_name': 'Honda', 'model': 'CBR 600'},
              {'brand_name': 'Honda', 'model': 'CBR 1000'},
            ],
          },
        };

        // Act
        final models = BrandLineModel.fromJsonList(response);

        // Assert
        expect(models.length, 2);
        expect(models[0].brandName, 'Honda');
        expect(models[0].model, 'CBR 600');
        expect(models[1].model, 'CBR 1000');
      });

      test('should return empty list when data is null', () {
        // Arrange
        final response = {'success': true};

        // Act
        final models = BrandLineModel.fromJsonList(response);

        // Assert
        expect(models, isEmpty);
      });

      test('should return empty list when lines is null', () {
        // Arrange
        final response = {'success': true, 'data': <String, dynamic>{}};

        // Act
        final models = BrandLineModel.fromJsonList(response);

        // Assert
        expect(models, isEmpty);
      });

      test('should handle empty lines array', () {
        // Arrange
        final response = {
          'success': true,
          'data': {'lines': <Map<String, dynamic>>[]},
        };

        // Act
        final models = BrandLineModel.fromJsonList(response);

        // Assert
        expect(models, isEmpty);
      });
    });

    group('toEntity', () {
      test('should convert model to entity', () {
        // Arrange
        const model = BrandLineModel(brandName: 'Suzuki', model: 'GSX-R');

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity, isA<BrandLineEntity>());
        expect(entity.brandName, 'Suzuki');
        expect(entity.model, 'GSX-R');
      });

      test('should create separate entity instance', () {
        // Arrange
        const model = BrandLineModel(brandName: 'BMW', model: 'S1000RR');

        // Act
        final entity = model.toEntity();

        // Assert - model and entity should be equal but not identical
        expect(entity.brandName, model.brandName);
        expect(entity.model, model.model);
      });
    });
  });
}
