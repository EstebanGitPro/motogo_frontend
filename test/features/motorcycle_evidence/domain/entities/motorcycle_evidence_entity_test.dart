import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/domain/entities/motorcycle_evidence_entity.dart';

void main() {
  group('MotorcycleEvidenceEntity', () {
    final testDate = DateTime(2024, 1, 15, 10, 30);

    group('constructor', () {
      test('should create instance with required fields', () {
        // Act
        final entity = MotorcycleEvidenceEntity(
          id: 'evidence-123',
          motorcycleId: 'moto-456',
          imageUrl: 'https://example.com/image.jpg',
          createdAt: testDate,
        );

        // Assert
        expect(entity.id, 'evidence-123');
        expect(entity.motorcycleId, 'moto-456');
        expect(entity.imageUrl, 'https://example.com/image.jpg');
        expect(entity.createdAt, testDate);
        expect(entity.angle, isNull);
        expect(entity.description, isNull);
      });

      test('should create instance with optional fields', () {
        // Act
        final entity = MotorcycleEvidenceEntity(
          id: 'evidence-123',
          motorcycleId: 'moto-456',
          imageUrl: 'https://example.com/image.jpg',
          createdAt: testDate,
          angle: 'Frontal',
          description: 'Foto del frente',
        );

        // Assert
        expect(entity.angle, 'Frontal');
        expect(entity.description, 'Foto del frente');
      });
    });

    group('Equatable', () {
      test('should be equal when all properties match', () {
        // Arrange
        final entity1 = MotorcycleEvidenceEntity(
          id: 'evidence-123',
          motorcycleId: 'moto-456',
          imageUrl: 'https://example.com/image.jpg',
          createdAt: testDate,
          angle: 'Lateral',
          description: 'Description',
        );

        final entity2 = MotorcycleEvidenceEntity(
          id: 'evidence-123',
          motorcycleId: 'moto-456',
          imageUrl: 'https://example.com/image.jpg',
          createdAt: testDate,
          angle: 'Lateral',
          description: 'Description',
        );

        // Assert
        expect(entity1, equals(entity2));
        expect(entity1.hashCode, equals(entity2.hashCode));
      });

      test('should not be equal when id differs', () {
        // Arrange
        final entity1 = MotorcycleEvidenceEntity(
          id: 'evidence-123',
          motorcycleId: 'moto-456',
          imageUrl: 'https://example.com/image.jpg',
          createdAt: testDate,
        );

        final entity2 = MotorcycleEvidenceEntity(
          id: 'evidence-789',
          motorcycleId: 'moto-456',
          imageUrl: 'https://example.com/image.jpg',
          createdAt: testDate,
        );

        // Assert
        expect(entity1, isNot(equals(entity2)));
      });

      test('props should include all fields', () {
        // Arrange
        final entity = MotorcycleEvidenceEntity(
          id: 'evidence-123',
          motorcycleId: 'moto-456',
          imageUrl: 'https://example.com/image.jpg',
          createdAt: testDate,
          angle: 'Rear',
          description: 'Back view',
        );

        // Assert
        expect(entity.props.length, 6);
        expect(entity.props, contains('evidence-123'));
        expect(entity.props, contains('moto-456'));
        expect(entity.props, contains('https://example.com/image.jpg'));
        expect(entity.props, contains('Rear'));
        expect(entity.props, contains('Back view'));
        expect(entity.props, contains(testDate));
      });
    });
  });
}
