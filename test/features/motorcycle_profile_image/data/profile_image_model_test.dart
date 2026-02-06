import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/motorcycle_profile_image/data/models/profile_image_model.dart';
import 'package:motogo_frontend/src/features/motorcycle_profile_image/domain/entities/profile_image_entity.dart';

void main() {
  group('ProfileImageModel', () {
    group('fromJson', () {
      test('parses JSON with nested data object', () {
        // Arrange
        final json = {
          'success': true,
          'message': 'Imagen obtenida',
          'data': {
            'motorcycle_id': 'abc123encoded',
            'profile_image_url': 'https://firebase.com/image.jpg',
          },
        };

        // Act
        final model = ProfileImageModel.fromJson(json);

        // Assert
        expect(model.motorcycleId, 'abc123encoded');
        expect(model.profileImageUrl, 'https://firebase.com/image.jpg');
      });

      test('parses JSON without nested data (flat structure)', () {
        // Arrange
        final json = {
          'motorcycle_id': 'flat-id',
          'profile_image_url': 'https://flat-url.jpg',
        };

        // Act
        final model = ProfileImageModel.fromJson(json);

        // Assert
        expect(model.motorcycleId, 'flat-id');
        expect(model.profileImageUrl, 'https://flat-url.jpg');
      });

      test('handles null profile_image_url', () {
        // Arrange
        final json = {
          'data': {
            'motorcycle_id': 'no-image-id',
            // profile_image_url not present
          },
        };

        // Act
        final model = ProfileImageModel.fromJson(json);

        // Assert
        expect(model.motorcycleId, 'no-image-id');
        expect(model.profileImageUrl, isNull);
      });

      test('handles missing motorcycle_id with empty string default', () {
        // Arrange
        final json = <String, dynamic>{
          'data': {'profile_image_url': 'https://url.jpg'},
        };

        // Act
        final model = ProfileImageModel.fromJson(json);

        // Assert
        expect(model.motorcycleId, '');
        expect(model.profileImageUrl, 'https://url.jpg');
      });
    });

    group('toJson', () {
      test('converts model to JSON with image_url key', () {
        // Arrange
        const model = ProfileImageModel(
          motorcycleId: 'moto-123',
          profileImageUrl: 'https://myimage.jpg',
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['image_url'], 'https://myimage.jpg');
        expect(json.containsKey('motorcycle_id'), isFalse);
      });

      test('toJson with null profileImageUrl', () {
        // Arrange
        const model = ProfileImageModel(motorcycleId: 'moto-456');

        // Act
        final json = model.toJson();

        // Assert
        expect(json['image_url'], isNull);
      });
    });

    group('fromEntity', () {
      test('creates model from entity', () {
        // Arrange
        const entity = ProfileImageEntity(
          motorcycleId: 'entity-id',
          profileImageUrl: 'https://entity-url.jpg',
        );

        // Act
        final model = ProfileImageModel.fromEntity(entity);

        // Assert
        expect(model.motorcycleId, 'entity-id');
        expect(model.profileImageUrl, 'https://entity-url.jpg');
      });
    });

    group('toEntity', () {
      test('converts model to entity', () {
        // Arrange
        const model = ProfileImageModel(
          motorcycleId: 'model-id',
          profileImageUrl: 'https://model-url.jpg',
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity, isA<ProfileImageEntity>());
        expect(entity.motorcycleId, 'model-id');
        expect(entity.profileImageUrl, 'https://model-url.jpg');
      });
    });

    group('copyWith', () {
      test('creates a copy with updated fields', () {
        // Arrange
        const model = ProfileImageModel(
          motorcycleId: 'original-id',
          profileImageUrl: 'https://original.jpg',
        );

        // Act
        final copy = model.copyWith(profileImageUrl: 'https://new.jpg');

        // Assert
        expect(copy.motorcycleId, 'original-id');
        expect(copy.profileImageUrl, 'https://new.jpg');
      });

      test('retains values when copyWith called with no parameters', () {
        // Arrange
        const model = ProfileImageModel(
          motorcycleId: 'same-id',
          profileImageUrl: 'https://same.jpg',
        );

        // Act
        final copy = model.copyWith();

        // Assert
        expect(copy.motorcycleId, 'same-id');
        expect(copy.profileImageUrl, 'https://same.jpg');
      });
    });
  });
}
