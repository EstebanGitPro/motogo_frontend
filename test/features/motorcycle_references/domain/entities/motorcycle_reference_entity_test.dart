import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/motorcycle_references/domain/entities/motorcycle_reference_entity.dart';

void main() {
  group('MotorcycleReferenceEntity', () {
    test('should create entity with all fields', () {
      const entity = MotorcycleReferenceEntity(
        id: 'ref-123',
        brandId: 'brand-456',
        brandName: 'Yamaha',
        model: 'MT-07',
        category: 'Naked',
        engineDisplacementCc: 689,
      );

      expect(entity.id, 'ref-123');
      expect(entity.brandId, 'brand-456');
      expect(entity.brandName, 'Yamaha');
      expect(entity.model, 'MT-07');
      expect(entity.category, 'Naked');
      expect(entity.engineDisplacementCc, 689);
    });

    test('should create entity with nullable fields as null', () {
      const entity = MotorcycleReferenceEntity(
        id: 'ref-123',
        brandId: 'brand-456',
        brandName: 'Honda',
        model: 'CB500F',
      );

      expect(entity.id, 'ref-123');
      expect(entity.brandName, 'Honda');
      expect(entity.model, 'CB500F');
      expect(entity.category, isNull);
      expect(entity.engineDisplacementCc, isNull);
    });

    group('displayName', () {
      test('should return full display name when all fields present', () {
        const entity = MotorcycleReferenceEntity(
          id: 'ref-123',
          brandId: 'brand-456',
          brandName: 'Suzuki',
          model: 'GSX-R600',
          category: 'Deportiva',
          engineDisplacementCc: 599,
        );

        expect(entity.displayName, 'Suzuki GSX-R600 (Deportiva - 599cc)');
      });

      test('should handle null category', () {
        const entity = MotorcycleReferenceEntity(
          id: 'ref-123',
          brandId: 'brand-456',
          brandName: 'Kawasaki',
          model: 'Ninja 400',
          engineDisplacementCc: 399,
        );

        expect(entity.displayName, 'Kawasaki Ninja 400 (399cc)');
      });

      test('should handle null engine displacement', () {
        const entity = MotorcycleReferenceEntity(
          id: 'ref-123',
          brandId: 'brand-456',
          brandName: 'Royal Enfield',
          model: 'Classic 350',
          category: 'Clásica',
        );

        expect(entity.displayName, 'Royal Enfield Classic 350 (Clásica)');
      });

      test('should handle both nullable fields as null', () {
        const entity = MotorcycleReferenceEntity(
          id: 'ref-123',
          brandId: 'brand-456',
          brandName: 'Bajaj',
          model: 'Pulsar NS200',
        );

        expect(entity.displayName, 'Bajaj Pulsar NS200');
      });
    });

    group('Equatable', () {
      test('should be equal when all properties match', () {
        const entity1 = MotorcycleReferenceEntity(
          id: 'ref-123',
          brandId: 'brand-456',
          brandName: 'Yamaha',
          model: 'MT-07',
          category: 'Naked',
          engineDisplacementCc: 689,
        );

        const entity2 = MotorcycleReferenceEntity(
          id: 'ref-123',
          brandId: 'brand-456',
          brandName: 'Yamaha',
          model: 'MT-07',
          category: 'Naked',
          engineDisplacementCc: 689,
        );

        expect(entity1, equals(entity2));
      });

      test('should not be equal when properties differ', () {
        const entity1 = MotorcycleReferenceEntity(
          id: 'ref-123',
          brandId: 'brand-456',
          brandName: 'Yamaha',
          model: 'MT-07',
        );

        const entity2 = MotorcycleReferenceEntity(
          id: 'ref-999',
          brandId: 'brand-456',
          brandName: 'Yamaha',
          model: 'MT-07',
        );

        expect(entity1, isNot(equals(entity2)));
      });
    });
  });
}
