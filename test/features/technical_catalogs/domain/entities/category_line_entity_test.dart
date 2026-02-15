import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/entities/category_line_entity.dart';

void main() {
  group('CategoryLineEntity', () {
    test('should create instance with required fields', () {
      const entity = CategoryLineEntity(
        model: 'Adventure 390',
        brand: 'KTM',
        engineDisplacement: 373,
      );

      expect(entity.model, 'Adventure 390');
      expect(entity.brand, 'KTM');
      expect(entity.engineDisplacement, 373);
    });

    test('should support value equality', () {
      const entity1 = CategoryLineEntity(
        model: 'Adventure 390',
        brand: 'KTM',
        engineDisplacement: 373,
      );
      const entity2 = CategoryLineEntity(
        model: 'Adventure 390',
        brand: 'KTM',
        engineDisplacement: 373,
      );

      expect(entity1, entity2);
    });

    test('should not be equal with different model', () {
      const entity1 = CategoryLineEntity(
        model: 'Adventure 390',
        brand: 'KTM',
        engineDisplacement: 373,
      );
      const entity2 = CategoryLineEntity(
        model: 'Duke 390',
        brand: 'KTM',
        engineDisplacement: 373,
      );

      expect(entity1, isNot(entity2));
    });

    test('should not be equal with different brand', () {
      const entity1 = CategoryLineEntity(
        model: 'Adventure 390',
        brand: 'KTM',
        engineDisplacement: 373,
      );
      const entity2 = CategoryLineEntity(
        model: 'Adventure 390',
        brand: 'BMW',
        engineDisplacement: 373,
      );

      expect(entity1, isNot(entity2));
    });

    test('props should contain all fields', () {
      const entity = CategoryLineEntity(
        model: 'FZ25',
        brand: 'Yamaha',
        engineDisplacement: 249,
      );

      expect(entity.props, [
        entity.model,
        entity.brand,
        entity.engineDisplacement,
      ]);
    });
  });
}
