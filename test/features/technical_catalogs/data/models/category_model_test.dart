import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/data/models/category_model.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/entities/category_entity.dart';

void main() {
  group('CategoryModel', () {
    group('constructor', () {
      test('should create instance with required fields', () {
        const model = CategoryModel(name: 'Adventure', lineCount: 3);

        expect(model.name, 'Adventure');
        expect(model.lineCount, 3);
      });

      test('should extend CategoryEntity', () {
        const model = CategoryModel(name: 'Enduro', lineCount: 5);

        expect(model, isA<CategoryEntity>());
      });
    });

    group('fromJson', () {
      test('should parse complete JSON correctly', () {
        final json = {'name': 'Adventure', 'line_count': 1};

        final model = CategoryModel.fromJson(json);

        expect(model.name, 'Adventure');
        expect(model.lineCount, 1);
      });

      test('should handle missing name with empty string', () {
        final json = {'line_count': 4};

        final model = CategoryModel.fromJson(json);

        expect(model.name, '');
        expect(model.lineCount, 4);
      });

      test('should handle missing line_count with zero', () {
        final json = {'name': 'Sport'};

        final model = CategoryModel.fromJson(json);

        expect(model.name, 'Sport');
        expect(model.lineCount, 0);
      });

      test('should handle empty JSON', () {
        final json = <String, dynamic>{};

        final model = CategoryModel.fromJson(json);

        expect(model.name, '');
        expect(model.lineCount, 0);
      });
    });

    group('fromJsonList', () {
      test('should parse HATEOAS response with categories', () {
        final response = {
          'success': true,
          'data': {
            'categories': [
              {'name': 'Adventure', 'line_count': 1},
              {'name': 'Enduro', 'line_count': 4},
            ],
          },
        };

        final models = CategoryModel.fromJsonList(response);

        expect(models.length, 2);
        expect(models[0].name, 'Adventure');
        expect(models[0].lineCount, 1);
        expect(models[1].name, 'Enduro');
        expect(models[1].lineCount, 4);
      });

      test('should return empty list when data is null', () {
        final response = {'success': true};

        final models = CategoryModel.fromJsonList(response);

        expect(models, isEmpty);
      });

      test('should return empty list when categories is null', () {
        final response = {'success': true, 'data': <String, dynamic>{}};

        final models = CategoryModel.fromJsonList(response);

        expect(models, isEmpty);
      });

      test('should handle empty categories array', () {
        final response = {
          'success': true,
          'data': {'categories': <Map<String, dynamic>>[]},
        };

        final models = CategoryModel.fromJsonList(response);

        expect(models, isEmpty);
      });
    });

    group('toEntity', () {
      test('should convert model to entity', () {
        const model = CategoryModel(name: 'Urban', lineCount: 8);

        final entity = model.toEntity();

        expect(entity, isA<CategoryEntity>());
        expect(entity.name, 'Urban');
        expect(entity.lineCount, 8);
      });

      test('should create separate entity instance', () {
        const model = CategoryModel(name: 'Scooter', lineCount: 3);

        final entity = model.toEntity();

        expect(entity.name, model.name);
        expect(entity.lineCount, model.lineCount);
      });
    });
  });
}
