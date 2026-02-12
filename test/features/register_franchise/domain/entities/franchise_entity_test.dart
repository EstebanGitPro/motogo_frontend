import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/register_franchise/domain/entities/franchise_entity.dart';

void main() {
  group('FranchiseEntity', () {
    group('constructor', () {
      test('should create instance with required fields', () {
        const entity = FranchiseEntity(name: 'MotoRed');

        expect(entity.name, 'MotoRed');
        expect(entity.id, isNull);
        expect(entity.description, isNull);
        expect(entity.branchIds, isEmpty);
      });

      test('should create instance with all fields', () {
        const entity = FranchiseEntity(
          id: 'franchise-123',
          name: 'MotoService',
          description: 'Red de talleres',
          branchIds: ['b1', 'b2'],
        );

        expect(entity.id, 'franchise-123');
        expect(entity.name, 'MotoService');
        expect(entity.description, 'Red de talleres');
        expect(entity.branchIds, ['b1', 'b2']);
      });
    });

    group('copyWith', () {
      const original = FranchiseEntity(
        id: 'franchise-123',
        name: 'Original',
        description: 'Desc original',
        branchIds: ['b1'],
      );

      test('should return copy with updated name', () {
        final copy = original.copyWith(name: 'Updated');

        expect(copy.name, 'Updated');
        expect(copy.id, 'franchise-123');
        expect(copy.description, 'Desc original');
        expect(copy.branchIds, ['b1']);
      });

      test('should return copy with updated branchIds', () {
        final copy = original.copyWith(branchIds: ['b1', 'b2', 'b3']);

        expect(copy.branchIds, ['b1', 'b2', 'b3']);
        expect(copy.name, 'Original');
      });

      test('should return copy with updated description', () {
        final copy = original.copyWith(description: 'New desc');
        expect(copy.description, 'New desc');
      });

      test('should return copy with updated id', () {
        final copy = original.copyWith(id: 'new-id');
        expect(copy.id, 'new-id');
      });

      test('should preserve all fields when no arguments', () {
        final copy = original.copyWith();

        expect(copy, equals(original));
      });
    });

    group('Equatable', () {
      test('should be equal when all properties match', () {
        const entity1 = FranchiseEntity(
          id: 'f1',
          name: 'Test',
          branchIds: ['b1'],
        );
        const entity2 = FranchiseEntity(
          id: 'f1',
          name: 'Test',
          branchIds: ['b1'],
        );

        expect(entity1, equals(entity2));
      });

      test('should not be equal when name differs', () {
        const entity1 = FranchiseEntity(name: 'A');
        const entity2 = FranchiseEntity(name: 'B');

        expect(entity1, isNot(equals(entity2)));
      });

      test('props should include all fields', () {
        const entity = FranchiseEntity(
          id: 'f1',
          name: 'Test',
          description: 'Desc',
          branchIds: ['b1'],
        );

        expect(entity.props.length, 4);
        expect(entity.props, contains('f1'));
        expect(entity.props, contains('Test'));
        expect(entity.props, contains('Desc'));
      });
    });
  });
}
