import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/entities/motorcycle_entity.dart';

void main() {
  group('MotorcycleEntity', () {
    group('constructor', () {
      test('should create instance with required licensePlate', () {
        // Act
        const entity = MotorcycleEntity(licensePlate: 'ABC123');

        // Assert
        expect(entity.licensePlate, 'ABC123');
        expect(entity.id, isNull);
        expect(entity.referenceId, isNull);
        expect(entity.year, isNull);
        expect(entity.currentMileage, isNull);
        expect(entity.ownerNotes, isNull);
        expect(entity.profileImageUrl, isNull);
      });

      test('should create instance with all fields', () {
        // Act
        const entity = MotorcycleEntity(
          id: 'moto-123',
          licensePlate: 'XYZ789',
          referenceId: 'ref-456',
          year: 2023,
          currentMileage: 15000,
          ownerNotes: 'Test notes',
          profileImageUrl: 'https://example.com/img.jpg',
        );

        // Assert
        expect(entity.id, 'moto-123');
        expect(entity.licensePlate, 'XYZ789');
        expect(entity.referenceId, 'ref-456');
        expect(entity.year, 2023);
        expect(entity.currentMileage, 15000);
        expect(entity.ownerNotes, 'Test notes');
        expect(entity.profileImageUrl, 'https://example.com/img.jpg');
      });
    });

    group('copyWith', () {
      const original = MotorcycleEntity(
        id: 'original-id',
        licensePlate: 'ABC123',
        referenceId: 'ref-1',
        year: 2020,
        currentMileage: 10000,
        ownerNotes: 'Original notes',
        profileImageUrl: 'https://original.com/img.jpg',
      );

      test('should copy with new id', () {
        final copy = original.copyWith(id: 'new-id');
        expect(copy.id, 'new-id');
        expect(copy.licensePlate, original.licensePlate);
      });

      test('should copy with new licensePlate', () {
        final copy = original.copyWith(licensePlate: 'NEW999');
        expect(copy.licensePlate, 'NEW999');
        expect(copy.id, original.id);
      });

      test('should copy with new year', () {
        final copy = original.copyWith(year: 2024);
        expect(copy.year, 2024);
      });

      test('should copy with new currentMileage', () {
        final copy = original.copyWith(currentMileage: 25000);
        expect(copy.currentMileage, 25000);
      });

      test('should copy with new ownerNotes', () {
        final copy = original.copyWith(ownerNotes: 'Updated notes');
        expect(copy.ownerNotes, 'Updated notes');
      });

      test('should copy with no changes when no args', () {
        final copy = original.copyWith();
        expect(copy.id, original.id);
        expect(copy.licensePlate, original.licensePlate);
        expect(copy.referenceId, original.referenceId);
        expect(copy.year, original.year);
        expect(copy.currentMileage, original.currentMileage);
        expect(copy.ownerNotes, original.ownerNotes);
        expect(copy.profileImageUrl, original.profileImageUrl);
      });
    });

    group('Equatable', () {
      test('should be equal when all properties match', () {
        const entity1 = MotorcycleEntity(
          id: 'id1',
          licensePlate: 'ABC123',
          year: 2022,
        );
        const entity2 = MotorcycleEntity(
          id: 'id1',
          licensePlate: 'ABC123',
          year: 2022,
        );

        expect(entity1, equals(entity2));
        expect(entity1.hashCode, equals(entity2.hashCode));
      });

      test('should not be equal when licensePlate differs', () {
        const entity1 = MotorcycleEntity(licensePlate: 'ABC123');
        const entity2 = MotorcycleEntity(licensePlate: 'XYZ789');

        expect(entity1, isNot(equals(entity2)));
      });

      test('props should include all fields', () {
        const entity = MotorcycleEntity(
          id: 'id',
          licensePlate: 'plate',
          referenceId: 'ref',
          year: 2020,
          currentMileage: 5000,
          ownerNotes: 'notes',
          profileImageUrl: 'url',
        );

        expect(entity.props.length, 7);
        expect(entity.props, contains('id'));
        expect(entity.props, contains('plate'));
        expect(entity.props, contains('ref'));
        expect(entity.props, contains(2020));
        expect(entity.props, contains(5000));
        expect(entity.props, contains('notes'));
        expect(entity.props, contains('url'));
      });
    });
  });
}
