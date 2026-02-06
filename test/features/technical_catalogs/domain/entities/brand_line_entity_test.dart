import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/entities/brand_line_entity.dart';

void main() {
  group('BrandLineEntity', () {
    group('constructor', () {
      test('should create instance with required fields', () {
        // Act
        const entity = BrandLineEntity(brandName: 'Honda', model: 'CBR 600RR');

        // Assert
        expect(entity.brandName, 'Honda');
        expect(entity.model, 'CBR 600RR');
      });

      test('should support const constructor', () {
        // Act & Assert
        const entity = BrandLineEntity(brandName: 'Yamaha', model: 'R1');
        expect(entity, isA<BrandLineEntity>());
      });
    });

    group('Equatable', () {
      test('should be equal when all properties match', () {
        // Arrange
        const entity1 = BrandLineEntity(brandName: 'Honda', model: 'CBR');
        const entity2 = BrandLineEntity(brandName: 'Honda', model: 'CBR');

        // Assert
        expect(entity1, equals(entity2));
        expect(entity1.hashCode, equals(entity2.hashCode));
      });

      test('should not be equal when brandName differs', () {
        // Arrange
        const entity1 = BrandLineEntity(brandName: 'Honda', model: 'CBR');
        const entity2 = BrandLineEntity(brandName: 'Yamaha', model: 'CBR');

        // Assert
        expect(entity1, isNot(equals(entity2)));
      });

      test('should not be equal when model differs', () {
        // Arrange
        const entity1 = BrandLineEntity(brandName: 'Honda', model: 'CBR 600');
        const entity2 = BrandLineEntity(brandName: 'Honda', model: 'CBR 1000');

        // Assert
        expect(entity1, isNot(equals(entity2)));
      });

      test('props should include all fields', () {
        // Arrange
        const entity = BrandLineEntity(brandName: 'Honda', model: 'CBR');

        // Assert
        expect(entity.props, contains('Honda'));
        expect(entity.props, contains('CBR'));
        expect(entity.props.length, 2);
      });
    });
  });
}
