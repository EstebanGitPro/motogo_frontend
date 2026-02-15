import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/catalogs/data/models/displacement_range_model.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/displacement_range_entity.dart';

void main() {
  group('DisplacementRangeModel', () {
    group('fromJson', () {
      test('parses valid JSON correctly', () {
        final json = {'range': 'BAJO'};

        final model = DisplacementRangeModel.fromJson(json);

        expect(model.range, 'BAJO');
      });

      test('defaults to empty string when range is null', () {
        final json = <String, dynamic>{'range': null};

        final model = DisplacementRangeModel.fromJson(json);

        expect(model.range, '');
      });

      test('defaults to empty string when range is missing', () {
        final json = <String, dynamic>{};

        final model = DisplacementRangeModel.fromJson(json);

        expect(model.range, '');
      });
    });

    group('fromJsonList', () {
      test('parses valid HATEOAS response', () {
        final response = {
          'data': {
            'displacements': [
              {'range': 'BAJO'},
              {'range': 'MEDIO'},
              {'range': 'ALTO'},
            ],
          },
        };

        final models = DisplacementRangeModel.fromJsonList(response);

        expect(models, hasLength(3));
        expect(models[0].range, 'BAJO');
        expect(models[1].range, 'MEDIO');
        expect(models[2].range, 'ALTO');
      });

      test('returns empty list when data is null', () {
        final response = <String, dynamic>{'data': null};

        final models = DisplacementRangeModel.fromJsonList(response);

        expect(models, isEmpty);
      });

      test('returns empty list when data key is missing', () {
        final response = <String, dynamic>{};

        final models = DisplacementRangeModel.fromJsonList(response);

        expect(models, isEmpty);
      });

      test('returns empty list when displacements is null', () {
        final response = {
          'data': <String, dynamic>{'displacements': null},
        };

        final models = DisplacementRangeModel.fromJsonList(response);

        expect(models, isEmpty);
      });

      test('returns empty list when displacements list is empty', () {
        final response = {
          'data': {'displacements': <dynamic>[]},
        };

        final models = DisplacementRangeModel.fromJsonList(response);

        expect(models, isEmpty);
      });
    });

    group('toEntity', () {
      test('converts model to DisplacementRangeEntity', () {
        const model = DisplacementRangeModel(range: 'MEDIO');

        final entity = model.toEntity();

        expect(entity, isA<DisplacementRangeEntity>());
        expect(entity.range, 'MEDIO');
      });
    });

    group('constructor', () {
      test('creates model with required range', () {
        const model = DisplacementRangeModel(range: 'ALTO');

        expect(model.range, 'ALTO');
      });
    });
  });
}
