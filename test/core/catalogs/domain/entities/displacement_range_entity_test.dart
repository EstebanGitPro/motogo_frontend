import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/displacement_range_entity.dart';

void main() {
  group('DisplacementRangeEntity', () {
    group('displayLabel', () {
      test('returns "Bajo (50-200cc)" for BAJO range', () {
        const entity = DisplacementRangeEntity(range: 'BAJO');

        expect(entity.displayLabel, 'Bajo (50-200cc)');
      });

      test('returns "Medio (200-500cc)" for MEDIO range', () {
        const entity = DisplacementRangeEntity(range: 'MEDIO');

        expect(entity.displayLabel, 'Medio (200-500cc)');
      });

      test('returns "Alto (500cc+)" for ALTO range', () {
        const entity = DisplacementRangeEntity(range: 'ALTO');

        expect(entity.displayLabel, 'Alto (500cc+)');
      });

      test('returns raw range for unknown value', () {
        const entity = DisplacementRangeEntity(range: 'CUSTOM');

        expect(entity.displayLabel, 'CUSTOM');
      });
    });

    group('Equatable', () {
      test('two entities with same range are equal', () {
        const entity1 = DisplacementRangeEntity(range: 'BAJO');
        const entity2 = DisplacementRangeEntity(range: 'BAJO');

        expect(entity1, equals(entity2));
      });

      test('two entities with different range are not equal', () {
        const entity1 = DisplacementRangeEntity(range: 'BAJO');
        const entity2 = DisplacementRangeEntity(range: 'ALTO');

        expect(entity1, isNot(equals(entity2)));
      });

      test('props contains range', () {
        const entity = DisplacementRangeEntity(range: 'MEDIO');

        expect(entity.props, ['MEDIO']);
      });
    });
  });
}
