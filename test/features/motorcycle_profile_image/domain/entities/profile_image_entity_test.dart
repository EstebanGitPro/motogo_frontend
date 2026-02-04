import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/motorcycle_profile_image/domain/entities/profile_image_entity.dart';

void main() {
  group('ProfileImageEntity', () {
    group('Constructor', () {
      test('should create entity with all fields', () {
        const entity = ProfileImageEntity(
          motorcycleId: 'moto-123',
          profileImageUrl: 'https://example.com/image.jpg',
        );

        expect(entity.motorcycleId, 'moto-123');
        expect(entity.profileImageUrl, 'https://example.com/image.jpg');
      });

      test('should create entity with null profileImageUrl', () {
        const entity = ProfileImageEntity(motorcycleId: 'moto-456');

        expect(entity.motorcycleId, 'moto-456');
        expect(entity.profileImageUrl, isNull);
      });
    });

    group('Equatable', () {
      test('should be equal when all properties match', () {
        const entity1 = ProfileImageEntity(
          motorcycleId: 'moto-123',
          profileImageUrl: 'https://example.com/image.jpg',
        );

        const entity2 = ProfileImageEntity(
          motorcycleId: 'moto-123',
          profileImageUrl: 'https://example.com/image.jpg',
        );

        expect(entity1, equals(entity2));
      });

      test('should not be equal when motorcycleId differs', () {
        const entity1 = ProfileImageEntity(
          motorcycleId: 'moto-123',
          profileImageUrl: 'https://example.com/image.jpg',
        );

        const entity2 = ProfileImageEntity(
          motorcycleId: 'moto-999',
          profileImageUrl: 'https://example.com/image.jpg',
        );

        expect(entity1, isNot(equals(entity2)));
      });

      test('should not be equal when profileImageUrl differs', () {
        const entity1 = ProfileImageEntity(
          motorcycleId: 'moto-123',
          profileImageUrl: 'https://example.com/image1.jpg',
        );

        const entity2 = ProfileImageEntity(
          motorcycleId: 'moto-123',
          profileImageUrl: 'https://example.com/image2.jpg',
        );

        expect(entity1, isNot(equals(entity2)));
      });

      test('should be equal when both have null profileImageUrl', () {
        const entity1 = ProfileImageEntity(motorcycleId: 'moto-123');
        const entity2 = ProfileImageEntity(motorcycleId: 'moto-123');

        expect(entity1, equals(entity2));
      });
    });

    group('copyWith', () {
      test('should create copy with updated motorcycleId', () {
        const original = ProfileImageEntity(
          motorcycleId: 'moto-123',
          profileImageUrl: 'https://example.com/image.jpg',
        );

        final copy = original.copyWith(motorcycleId: 'moto-new');

        expect(copy.motorcycleId, 'moto-new');
        expect(copy.profileImageUrl, 'https://example.com/image.jpg');
      });

      test('should create copy with updated profileImageUrl', () {
        const original = ProfileImageEntity(
          motorcycleId: 'moto-123',
          profileImageUrl: 'https://example.com/old.jpg',
        );

        final copy = original.copyWith(
          profileImageUrl: 'https://example.com/new.jpg',
        );

        expect(copy.motorcycleId, 'moto-123');
        expect(copy.profileImageUrl, 'https://example.com/new.jpg');
      });

      test('should create identical copy when no parameters provided', () {
        const original = ProfileImageEntity(
          motorcycleId: 'moto-123',
          profileImageUrl: 'https://example.com/image.jpg',
        );

        final copy = original.copyWith();

        expect(copy, equals(original));
        expect(copy.motorcycleId, original.motorcycleId);
        expect(copy.profileImageUrl, original.profileImageUrl);
      });

      test('should create copy with all parameters updated', () {
        const original = ProfileImageEntity(
          motorcycleId: 'moto-123',
          profileImageUrl: 'https://example.com/old.jpg',
        );

        final copy = original.copyWith(
          motorcycleId: 'moto-new',
          profileImageUrl: 'https://example.com/new.jpg',
        );

        expect(copy.motorcycleId, 'moto-new');
        expect(copy.profileImageUrl, 'https://example.com/new.jpg');
      });
    });

    group('props', () {
      test('should return list with motorcycleId and profileImageUrl', () {
        const entity = ProfileImageEntity(
          motorcycleId: 'moto-123',
          profileImageUrl: 'https://example.com/image.jpg',
        );

        expect(entity.props, ['moto-123', 'https://example.com/image.jpg']);
      });

      test('should include null in props when profileImageUrl is null', () {
        const entity = ProfileImageEntity(motorcycleId: 'moto-123');

        expect(entity.props, ['moto-123', null]);
      });
    });
  });
}
