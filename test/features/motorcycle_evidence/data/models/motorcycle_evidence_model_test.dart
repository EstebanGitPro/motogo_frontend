import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/data/models/motorcycle_evidence_model.dart';

void main() {
  group('MotorcycleEvidenceModel', () {
    group('fromJson (wrapper format)', () {
      test('should parse from data wrapper', () {
        final json = {
          'data': <String, dynamic>{
            'id': 'ev-123',
            'motorcycle_id': 'moto-456',
            'image_url': 'https://example.com/img.jpg',
            'angle': 'Frontal',
            'description': 'Front view',
            'created_at': '2024-01-15T10:30:00Z',
          },
        };

        final model = MotorcycleEvidenceModel.fromJson(json);

        expect(model.id, 'ev-123');
        expect(model.motorcycleId, 'moto-456');
        expect(model.imageUrl, 'https://example.com/img.jpg');
        expect(model.angle, 'Frontal');
        expect(model.description, 'Front view');
        expect(model.createdAt, '2024-01-15T10:30:00Z');
      });

      test('should parse without data wrapper (flat format)', () {
        final json = {
          'id': 'ev-123',
          'motorcycle_id': 'moto-456',
          'image_url': 'https://example.com/img.jpg',
          'created_at': '2024-01-15',
        };

        final model = MotorcycleEvidenceModel.fromJson(json);

        expect(model.id, 'ev-123');
        expect(model.angle, isNull);
        expect(model.description, isNull);
      });

      test('should use defaults for missing fields', () {
        final model = MotorcycleEvidenceModel.fromJson(<String, dynamic>{});

        expect(model.id, '');
        expect(model.motorcycleId, '');
        expect(model.imageUrl, '');
        expect(model.angle, isNull);
        expect(model.description, isNull);
        expect(model.createdAt, '');
      });
    });

    group('fromDataJson', () {
      test('should parse from flat JSON', () {
        final json = {
          'id': 'ev-abc',
          'motorcycle_id': 'moto-xyz',
          'image_url': 'https://example.com/photo.jpg',
          'angle': 'Lateral',
          'description': 'Side view',
          'created_at': '2024-03-10',
        };

        final model = MotorcycleEvidenceModel.fromDataJson(json);

        expect(model.id, 'ev-abc');
        expect(model.motorcycleId, 'moto-xyz');
        expect(model.imageUrl, 'https://example.com/photo.jpg');
        expect(model.angle, 'Lateral');
        expect(model.description, 'Side view');
      });

      test('should use defaults for missing fields in fromDataJson', () {
        final model = MotorcycleEvidenceModel.fromDataJson(<String, dynamic>{});

        expect(model.id, '');
        expect(model.motorcycleId, '');
        expect(model.imageUrl, '');
        expect(model.angle, isNull);
        expect(model.description, isNull);
        expect(model.createdAt, '');
      });
    });

    group('toEntity', () {
      test('should convert all fields to entity', () {
        const model = MotorcycleEvidenceModel(
          id: 'ev-123',
          motorcycleId: 'moto-456',
          imageUrl: 'https://example.com/img.jpg',
          angle: 'Rear',
          description: 'Back view',
          createdAt: '2024-01-15T10:30:00Z',
        );

        final entity = model.toEntity();

        expect(entity.id, 'ev-123');
        expect(entity.motorcycleId, 'moto-456');
        expect(entity.imageUrl, 'https://example.com/img.jpg');
        expect(entity.angle, 'Rear');
        expect(entity.description, 'Back view');
        expect(entity.createdAt.year, 2024);
      });

      test('should fallback to DateTime.now for invalid date', () {
        const model = MotorcycleEvidenceModel(
          id: 'ev-1',
          motorcycleId: 'moto-1',
          imageUrl: 'https://example.com/img.jpg',
          createdAt: 'not-a-date',
        );

        final before = DateTime.now();
        final entity = model.toEntity();
        final after = DateTime.now();

        expect(
          entity.createdAt.isAfter(before.subtract(const Duration(seconds: 1))),
          isTrue,
        );
        expect(
          entity.createdAt.isBefore(after.add(const Duration(seconds: 1))),
          isTrue,
        );
      });
    });
  });
}
