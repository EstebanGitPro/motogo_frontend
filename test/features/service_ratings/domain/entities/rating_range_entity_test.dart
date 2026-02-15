import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/service_ratings/domain/entities/rating_range_entity.dart';

void main() {
  group('RatingRangeEntity', () {
    group('constructor', () {
      test('creates entity with required fields', () {
        const entity = RatingRangeEntity(value: 5, label: 'Excelente');

        expect(entity.value, 5);
        expect(entity.label, 'Excelente');
      });
    });

    group('Equatable', () {
      test('two entities with same value and label are equal', () {
        const entity1 = RatingRangeEntity(value: 3, label: 'Regular');
        const entity2 = RatingRangeEntity(value: 3, label: 'Regular');

        expect(entity1, equals(entity2));
      });

      test('two entities with different value are not equal', () {
        const entity1 = RatingRangeEntity(value: 3, label: 'Regular');
        const entity2 = RatingRangeEntity(value: 4, label: 'Regular');

        expect(entity1, isNot(equals(entity2)));
      });

      test('two entities with different label are not equal', () {
        const entity1 = RatingRangeEntity(value: 3, label: 'Regular');
        const entity2 = RatingRangeEntity(value: 3, label: 'Bueno');

        expect(entity1, isNot(equals(entity2)));
      });

      test('props contains value and label', () {
        const entity = RatingRangeEntity(value: 5, label: 'Excelente');

        expect(entity.props, [5, 'Excelente']);
      });
    });
  });
}
