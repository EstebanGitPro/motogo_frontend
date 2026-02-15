import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/data/models/category_line_model.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/entities/category_line_entity.dart';

void main() {
  group('CategoryLineModel', () {
    group('constructor', () {
      test('should create instance with required fields', () {
        const model = CategoryLineModel(
          model: 'Adventure 390',
          brand: 'KTM',
          engineDisplacement: 373,
        );

        expect(model.model, 'Adventure 390');
        expect(model.brand, 'KTM');
        expect(model.engineDisplacement, 373);
      });

      test('should extend CategoryLineEntity', () {
        const model = CategoryLineModel(
          model: 'FZ25',
          brand: 'Yamaha',
          engineDisplacement: 249,
        );

        expect(model, isA<CategoryLineEntity>());
      });
    });

    group('fromJson', () {
      test('should parse complete JSON correctly', () {
        final json = {
          'model': 'Adventure 390',
          'brand': 'KTM',
          'engine_displacement': 373,
        };

        final model = CategoryLineModel.fromJson(json);

        expect(model.model, 'Adventure 390');
        expect(model.brand, 'KTM');
        expect(model.engineDisplacement, 373);
      });

      test('should handle missing model with empty string', () {
        final json = {'brand': 'KTM', 'engine_displacement': 373};

        final model = CategoryLineModel.fromJson(json);

        expect(model.model, '');
        expect(model.brand, 'KTM');
        expect(model.engineDisplacement, 373);
      });

      test('should handle missing brand with empty string', () {
        final json = {'model': 'Duke 390', 'engine_displacement': 373};

        final model = CategoryLineModel.fromJson(json);

        expect(model.model, 'Duke 390');
        expect(model.brand, '');
        expect(model.engineDisplacement, 373);
      });

      test('should handle missing engine_displacement with zero', () {
        final json = {'model': 'Duke 390', 'brand': 'KTM'};

        final model = CategoryLineModel.fromJson(json);

        expect(model.model, 'Duke 390');
        expect(model.brand, 'KTM');
        expect(model.engineDisplacement, 0);
      });

      test('should handle empty JSON', () {
        final json = <String, dynamic>{};

        final model = CategoryLineModel.fromJson(json);

        expect(model.model, '');
        expect(model.brand, '');
        expect(model.engineDisplacement, 0);
      });
    });

    group('fromJsonList', () {
      test('should parse HATEOAS response with lines', () {
        final response = {
          'success': true,
          'data': {
            'category': 'Adventure',
            'lines': [
              {
                'model': 'Adventure 390',
                'brand': 'KTM',
                'engine_displacement': 373,
              },
              {
                'model': 'R 1250 GS',
                'brand': 'BMW',
                'engine_displacement': 1254,
              },
            ],
          },
        };

        final models = CategoryLineModel.fromJsonList(response);

        expect(models.length, 2);
        expect(models[0].model, 'Adventure 390');
        expect(models[0].brand, 'KTM');
        expect(models[0].engineDisplacement, 373);
        expect(models[1].model, 'R 1250 GS');
        expect(models[1].brand, 'BMW');
      });

      test('should return empty list when data is null', () {
        final response = {'success': true};

        final models = CategoryLineModel.fromJsonList(response);

        expect(models, isEmpty);
      });

      test('should return empty list when lines is null', () {
        final response = {
          'success': true,
          'data': {'category': 'Adventure'},
        };

        final models = CategoryLineModel.fromJsonList(response);

        expect(models, isEmpty);
      });

      test('should handle empty lines array', () {
        final response = {
          'success': true,
          'data': {'category': 'Adventure', 'lines': <Map<String, dynamic>>[]},
        };

        final models = CategoryLineModel.fromJsonList(response);

        expect(models, isEmpty);
      });
    });

    group('toEntity', () {
      test('should convert model to entity', () {
        const model = CategoryLineModel(
          model: 'FZ25',
          brand: 'Yamaha',
          engineDisplacement: 249,
        );

        final entity = model.toEntity();

        expect(entity, isA<CategoryLineEntity>());
        expect(entity.model, 'FZ25');
        expect(entity.brand, 'Yamaha');
        expect(entity.engineDisplacement, 249);
      });

      test('should create separate entity instance', () {
        const model = CategoryLineModel(
          model: 'CBR 600',
          brand: 'Honda',
          engineDisplacement: 599,
        );

        final entity = model.toEntity();

        expect(entity.model, model.model);
        expect(entity.brand, model.brand);
        expect(entity.engineDisplacement, model.engineDisplacement);
      });
    });
  });
}
