import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/entities/category_entity.dart';

void main() {
  group('CategoryEntity', () {
    test('should create instance with required fields', () {
      const entity = CategoryEntity(name: 'Adventure', lineCount: 3);

      expect(entity.name, 'Adventure');
      expect(entity.lineCount, 3);
    });

    test('should support value equality', () {
      const entity1 = CategoryEntity(name: 'Enduro', lineCount: 5);
      const entity2 = CategoryEntity(name: 'Enduro', lineCount: 5);

      expect(entity1, entity2);
    });

    test('should not be equal with different name', () {
      const entity1 = CategoryEntity(name: 'Enduro', lineCount: 5);
      const entity2 = CategoryEntity(name: 'Sport', lineCount: 5);

      expect(entity1, isNot(entity2));
    });

    test('should not be equal with different lineCount', () {
      const entity1 = CategoryEntity(name: 'Enduro', lineCount: 5);
      const entity2 = CategoryEntity(name: 'Enduro', lineCount: 2);

      expect(entity1, isNot(entity2));
    });

    test('props should contain name and lineCount', () {
      const entity = CategoryEntity(name: 'Urban', lineCount: 10);

      expect(entity.props, [entity.name, entity.lineCount]);
    });
  });
}
