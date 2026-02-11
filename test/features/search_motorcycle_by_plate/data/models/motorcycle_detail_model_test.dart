import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/data/models/motorcycle_detail_model.dart';

void main() {
  group('MotorcycleReferenceInfoModel', () {
    group('fromJson', () {
      test('should parse all fields from valid JSON', () {
        final json = {
          'brand_name': 'Yamaha',
          'model': 'MT-07',
          'category': 'Naked',
          'engine_displacement_cc': 689,
        };

        final model = MotorcycleReferenceInfoModel.fromJson(json);

        expect(model.brandName, 'Yamaha');
        expect(model.model, 'MT-07');
        expect(model.category, 'Naked');
        expect(model.engineDisplacementCc, 689);
      });

      test('should use defaults for missing/null fields', () {
        final model = MotorcycleReferenceInfoModel.fromJson({});

        expect(model.brandName, '');
        expect(model.model, '');
        expect(model.category, '');
        expect(model.engineDisplacementCc, 0);
      });

      test('should handle numeric values as doubles', () {
        final json = {
          'brand_name': 'Honda',
          'model': 'CB500',
          'category': 'Sport',
          'engine_displacement_cc': 500.0,
        };

        final model = MotorcycleReferenceInfoModel.fromJson(json);

        expect(model.engineDisplacementCc, 500);
      });
    });

    group('toEntity', () {
      test('should map all fields correctly', () {
        const model = MotorcycleReferenceInfoModel(
          brandName: 'Yamaha',
          model: 'MT-07',
          category: 'Naked',
          engineDisplacementCc: 689,
        );

        final entity = model.toEntity();

        expect(entity.brandName, 'Yamaha');
        expect(entity.model, 'MT-07');
        expect(entity.category, 'Naked');
        expect(entity.engineDisplacementCc, 689);
      });
    });
  });

  group('MotorcycleDetailModel', () {
    final validJson = {
      'id': 'moto-123',
      'license_plate': 'ABC12D',
      'year': 2023,
      'current_mileage': 5000,
      'profile_image_url': 'https://example.com/profile.jpg',
      'reference': {
        'brand_name': 'Yamaha',
        'model': 'MT-07',
        'category': 'Naked',
        'engine_displacement_cc': 689,
      },
      'diagnostics': [
        {
          'id': 'diag-1',
          'motorcycle_id': 'moto-123',
          'problem_description': 'Ruido extraño',
          'date': '2024-01-15',
          'sent_via_whatsapp': true,
        },
      ],
      'evidence': [
        {
          'id': 'ev-1',
          'motorcycle_id': 'moto-123',
          'image_url': 'https://example.com/img.jpg',
          'angle': 'Frontal',
          'created_at': '2024-01-15',
        },
      ],
    };

    group('fromJson', () {
      test('should parse all fields from valid JSON', () {
        final model = MotorcycleDetailModel.fromJson(validJson);

        expect(model.id, 'moto-123');
        expect(model.licensePlate, 'ABC12D');
        expect(model.year, 2023);
        expect(model.currentMileage, 5000);
        expect(model.profileImageUrl, 'https://example.com/profile.jpg');
        expect(model.reference.brandName, 'Yamaha');
        expect(model.diagnostics.length, 1);
        expect(model.evidence.length, 1);
      });

      test('should use defaults for missing/null fields', () {
        final model = MotorcycleDetailModel.fromJson({});

        expect(model.id, '');
        expect(model.licensePlate, '');
        expect(model.year, 0);
        expect(model.currentMileage, 0);
        expect(model.profileImageUrl, isNull);
        expect(model.diagnostics, isEmpty);
        expect(model.evidence, isEmpty);
      });

      test('should handle null reference as empty map', () {
        final json = {
          'id': 'moto-123',
          'license_plate': 'ABC12D',
          'year': 2023,
          'current_mileage': 5000,
          'reference': null,
        };

        final model = MotorcycleDetailModel.fromJson(json);

        expect(model.reference.brandName, '');
        expect(model.reference.model, '');
      });

      test('should handle null diagnostics list', () {
        final json = {
          'id': 'moto-123',
          'license_plate': 'ABC12D',
          'year': 2023,
          'current_mileage': 5000,
          'reference': <String, dynamic>{},
          'diagnostics': null,
        };

        final model = MotorcycleDetailModel.fromJson(json);

        expect(model.diagnostics, isEmpty);
      });

      test('should handle null evidence list', () {
        final json = {
          'id': 'moto-123',
          'license_plate': 'ABC12D',
          'year': 2023,
          'current_mileage': 5000,
          'reference': <String, dynamic>{},
          'evidence': null,
        };

        final model = MotorcycleDetailModel.fromJson(json);

        expect(model.evidence, isEmpty);
      });

      test('should handle non-list diagnostics value', () {
        final json = {
          'id': 'moto-123',
          'license_plate': 'ABC12D',
          'year': 2023,
          'current_mileage': 5000,
          'reference': <String, dynamic>{},
          'diagnostics': 'not-a-list',
        };

        final model = MotorcycleDetailModel.fromJson(json);

        expect(model.diagnostics, isEmpty);
      });

      test('should handle non-list evidence value', () {
        final json = {
          'id': 'moto-123',
          'license_plate': 'ABC12D',
          'year': 2023,
          'current_mileage': 5000,
          'reference': <String, dynamic>{},
          'evidence': 42,
        };

        final model = MotorcycleDetailModel.fromJson(json);

        expect(model.evidence, isEmpty);
      });

      test('should handle numeric values as doubles', () {
        final json = {
          'id': 'moto-123',
          'license_plate': 'ABC12D',
          'year': 2023.0,
          'current_mileage': 12500.0,
          'reference': <String, dynamic>{},
        };

        final model = MotorcycleDetailModel.fromJson(json);

        expect(model.year, 2023);
        expect(model.currentMileage, 12500);
      });
    });

    group('toEntity', () {
      test('should map all fields correctly to entity', () {
        final model = MotorcycleDetailModel.fromJson(validJson);

        final entity = model.toEntity();

        expect(entity.id, 'moto-123');
        expect(entity.licensePlate, 'ABC12D');
        expect(entity.year, 2023);
        expect(entity.currentMileage, 5000);
        expect(entity.profileImageUrl, 'https://example.com/profile.jpg');
        expect(entity.reference.brandName, 'Yamaha');
        expect(entity.diagnostics.length, 1);
        expect(entity.diagnostics.first.id, 'diag-1');
        expect(entity.evidence.length, 1);
        expect(entity.evidence.first.id, 'ev-1');
      });

      test('should handle empty diagnostics and evidence', () {
        final json = {
          'id': 'moto-123',
          'license_plate': 'ABC12D',
          'year': 2023,
          'current_mileage': 5000,
          'reference': {
            'brand_name': 'Honda',
            'model': 'CB500',
            'category': 'Sport',
            'engine_displacement_cc': 500,
          },
        };

        final entity = MotorcycleDetailModel.fromJson(json).toEntity();

        expect(entity.diagnostics, isEmpty);
        expect(entity.evidence, isEmpty);
      });
    });
  });
}
