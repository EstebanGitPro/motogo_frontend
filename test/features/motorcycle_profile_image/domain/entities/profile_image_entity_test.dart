import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/motorcycle_profile_image/domain/entities/profile_image_entity.dart';

void main() {
  group('ProfileImageEntity', () {
    group('constructor', () {
      test('should create instance with required motorcycleId', () {
        // Act
        const entity = ProfileImageEntity(motorcycleId: 'moto-123');

        // Assert
        expect(entity.motorcycleId, 'moto-123');
        expect(entity.profileImageUrl, isNull);
      });

      test('should create instance with both fields', () {
        // Act
        const entity = ProfileImageEntity(
          motorcycleId: 'moto-456',
          profileImageUrl: 'https://example.com/image.jpg',
        );

        // Assert
        expect(entity.motorcycleId, 'moto-456');
        expect(entity.profileImageUrl, 'https://example.com/image.jpg');
      });
    });

    group('copyWith', () {
      test('should copy with new motorcycleId', () {
        // Arrange
        const original = ProfileImageEntity(
          motorcycleId: 'original-id',
          profileImageUrl: 'https://example.com/original.jpg',
        );

        // Act
        final copy = original.copyWith(motorcycleId: 'new-id');

        // Assert
        expect(copy.motorcycleId, 'new-id');
        expect(copy.profileImageUrl, 'https://example.com/original.jpg');
      });

      test('should copy with new profileImageUrl', () {
        // Arrange
        const original = ProfileImageEntity(
          motorcycleId: 'moto-id',
          profileImageUrl: 'https://example.com/original.jpg',
        );

        // Act
        final copy = original.copyWith(
          profileImageUrl: 'https://example.com/new.jpg',
        );

        // Assert
        expect(copy.motorcycleId, 'moto-id');
        expect(copy.profileImageUrl, 'https://example.com/new.jpg');
      });

      test('should copy with all fields unchanged when no args', () {
        // Arrange
        const original = ProfileImageEntity(
          motorcycleId: 'moto-id',
          profileImageUrl: 'https://example.com/image.jpg',
        );

        // Act
        final copy = original.copyWith();

        // Assert
        expect(copy.motorcycleId, original.motorcycleId);
        expect(copy.profileImageUrl, original.profileImageUrl);
      });
    });

    group('Equatable', () {
      test('should be equal when all properties match', () {
        // Arrange
        const entity1 = ProfileImageEntity(
          motorcycleId: 'moto-123',
          profileImageUrl: 'https://example.com/img.jpg',
        );
        const entity2 = ProfileImageEntity(
          motorcycleId: 'moto-123',
          profileImageUrl: 'https://example.com/img.jpg',
        );

        // Assert
        expect(entity1, equals(entity2));
      });

      test('props should include both fields', () {
        // Arrange
        const entity = ProfileImageEntity(
          motorcycleId: 'moto-123',
          profileImageUrl: 'url',
        );

        // Assert
        expect(entity.props, contains('moto-123'));
        expect(entity.props, contains('url'));
      });
    });
  });
}
