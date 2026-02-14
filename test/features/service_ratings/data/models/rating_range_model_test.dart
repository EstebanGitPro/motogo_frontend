import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/service_ratings/data/models/rating_range_model.dart';
import 'package:motogo_frontend/src/features/service_ratings/domain/entities/rating_range_entity.dart';

void main() {
  group('RatingRangeModel', () {
    group('fromJson', () {
      test('parses valid JSON correctly', () {
        final json = {'value': 5, 'label': 'Excelente'};

        final model = RatingRangeModel.fromJson(json);

        expect(model.value, 5);
        expect(model.label, 'Excelente');
      });

      test('defaults value to 0 when null', () {
        final json = <String, dynamic>{'value': null, 'label': 'Test'};

        final model = RatingRangeModel.fromJson(json);

        expect(model.value, 0);
      });

      test('defaults label to empty string when null', () {
        final json = <String, dynamic>{'value': 3, 'label': null};

        final model = RatingRangeModel.fromJson(json);

        expect(model.label, '');
      });

      test('defaults all fields when JSON is empty', () {
        final json = <String, dynamic>{};

        final model = RatingRangeModel.fromJson(json);

        expect(model.value, 0);
        expect(model.label, '');
      });
    });

    group('toEntity', () {
      test('converts to RatingRangeEntity correctly', () {
        const model = RatingRangeModel(value: 4, label: 'Bueno');

        final entity = model.toEntity();

        expect(entity, isA<RatingRangeEntity>());
        expect(entity.value, 4);
        expect(entity.label, 'Bueno');
      });
    });

    group('constructor', () {
      test('creates model with required fields', () {
        const model = RatingRangeModel(value: 1, label: 'Malo');

        expect(model.value, 1);
        expect(model.label, 'Malo');
      });
    });
  });
}
