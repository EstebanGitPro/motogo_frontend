import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/entities/motorcycle_entity.dart';

void main() {
  group('MotorcycleEntity', () {
    test('should create entity with all fields', () {
      const entity = MotorcycleEntity(
        id: 'moto-123',
        licensePlate: 'ABC12D',
        referenceId: 'ref-456',
        year: 2023,
        currentMileage: 15000,
        ownerNotes: 'Mi moto favorita',
      );

      expect(entity.id, 'moto-123');
      expect(entity.licensePlate, 'ABC12D');
      expect(entity.referenceId, 'ref-456');
      expect(entity.year, 2023);
      expect(entity.currentMileage, 15000);
      expect(entity.ownerNotes, 'Mi moto favorita');
    });

    test('should create entity with only required fields', () {
      const entity = MotorcycleEntity(licensePlate: 'XYZ123');

      expect(entity.licensePlate, 'XYZ123');
      expect(entity.id, isNull);
      expect(entity.referenceId, isNull);
      expect(entity.year, isNull);
      expect(entity.currentMileage, isNull);
      expect(entity.ownerNotes, isNull);
    });

    group('copyWith', () {
      test('should copy with updated fields', () {
        const original = MotorcycleEntity(
          id: 'moto-123',
          licensePlate: 'ABC12D',
          referenceId: 'ref-456',
          year: 2023,
          currentMileage: 15000,
        );

        final copy = original.copyWith(
          licensePlate: 'NEW12X',
          currentMileage: 20000,
        );

        expect(copy.id, 'moto-123');
        expect(copy.licensePlate, 'NEW12X');
        expect(copy.referenceId, 'ref-456');
        expect(copy.year, 2023);
        expect(copy.currentMileage, 20000);
      });

      test('should preserve original when no changes', () {
        const original = MotorcycleEntity(licensePlate: 'ABC12D', year: 2022);

        final copy = original.copyWith();

        expect(copy.licensePlate, original.licensePlate);
        expect(copy.year, original.year);
      });

      test('should update referenceId', () {
        const original = MotorcycleEntity(licensePlate: 'ABC12D');

        final copy = original.copyWith(referenceId: 'new-ref-789');

        expect(copy.referenceId, 'new-ref-789');
      });
    });

    group('Equatable', () {
      test('should be equal when all properties match', () {
        const entity1 = MotorcycleEntity(
          id: 'moto-123',
          licensePlate: 'ABC12D',
          referenceId: 'ref-456',
          year: 2023,
        );

        const entity2 = MotorcycleEntity(
          id: 'moto-123',
          licensePlate: 'ABC12D',
          referenceId: 'ref-456',
          year: 2023,
        );

        expect(entity1, equals(entity2));
      });

      test('should not be equal when referenceId differs', () {
        const entity1 = MotorcycleEntity(
          licensePlate: 'ABC12D',
          referenceId: 'ref-456',
        );

        const entity2 = MotorcycleEntity(
          licensePlate: 'ABC12D',
          referenceId: 'ref-789',
        );

        expect(entity1, isNot(equals(entity2)));
      });
    });
  });
}
