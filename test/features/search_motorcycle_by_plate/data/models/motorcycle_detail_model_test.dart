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
    // Evidence is nested inside diagnostics, matching actual backend response
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
          'evidence': [
            {
              'id': 'ev-1',
              'image_url': 'https://example.com/img.jpg',
              'description': 'Foto frontal',
              'created_at': '2024-01-15',
            },
          ],
        },
      ],
      'permitted_branches': [
        {'id': 'branch-1', 'name': 'Taller Norte'},
        {'id': 'branch-2', 'name': 'Taller Sur'},
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
        expect(model.permittedBranches.length, 2);
        expect(model.permittedBranches[0].id, 'branch-1');
        expect(model.permittedBranches[0].name, 'Taller Norte');
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
        expect(model.permittedBranches, isEmpty);
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

      test('should handle diagnostics with no evidence', () {
        final json = {
          'id': 'moto-123',
          'license_plate': 'ABC12D',
          'year': 2023,
          'current_mileage': 5000,
          'reference': <String, dynamic>{},
          'diagnostics': [
            {
              'id': 'diag-1',
              'motorcycle_id': 'moto-123',
              'problem_description': 'Test',
              'date': '2024-01-15',
            },
          ],
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

      test('should handle non-list evidence inside diagnostic', () {
        final json = {
          'id': 'moto-123',
          'license_plate': 'ABC12D',
          'year': 2023,
          'current_mileage': 5000,
          'reference': <String, dynamic>{},
          'diagnostics': [
            {
              'id': 'diag-1',
              'motorcycle_id': 'moto-123',
              'problem_description': 'Test',
              'date': '2024-01-15',
              'evidence': 42,
            },
          ],
        };

        final model = MotorcycleDetailModel.fromJson(json);

        expect(model.evidence, isEmpty);
      });

      test('should parse top-level evidence field (HU16-19)', () {
        final json = {
          'id': 'moto-123',
          'license_plate': 'ABC12D',
          'year': 2023,
          'current_mileage': 5000,
          'reference': <String, dynamic>{},
          'evidence': [
            {
              'id': 'ev-top-1',
              'motorcycle_id': 'moto-123',
              'angle': 'frontal',
              'image_url': 'https://example.com/front.jpg',
              'description': 'Foto frontal',
              'created_at': '2024-01-15T10:00:00Z',
            },
            {
              'id': 'ev-top-2',
              'motorcycle_id': 'moto-123',
              'angle': 'lateral',
              'image_url': 'https://example.com/side.jpg',
              'description': null,
              'created_at': '2024-01-15T10:01:00Z',
            },
          ],
        };

        final model = MotorcycleDetailModel.fromJson(json);

        expect(model.evidence.length, 2);
        expect(model.evidence[0].id, 'ev-top-1');
        expect(model.evidence[0].imageUrl, 'https://example.com/front.jpg');
        expect(model.evidence[0].angle, 'frontal');
        expect(model.evidence[1].id, 'ev-top-2');
        expect(model.evidence[1].description, isNull);
      });

      test('should prioritize top-level evidence over diagnostic evidence', () {
        final json = {
          'id': 'moto-123',
          'license_plate': 'ABC12D',
          'year': 2023,
          'current_mileage': 5000,
          'reference': <String, dynamic>{},
          'evidence': [
            {
              'id': 'ev-top-1',
              'motorcycle_id': 'moto-123',
              'image_url': 'https://example.com/top.jpg',
              'created_at': '2024-01-15',
            },
          ],
          'diagnostics': [
            {
              'id': 'diag-1',
              'motorcycle_id': 'moto-123',
              'problem_description': 'Test',
              'date': '2024-01-15',
              'evidence': [
                {
                  'id': 'ev-diag-1',
                  'image_url': 'https://example.com/diag.jpg',
                  'created_at': '2024-01-15',
                },
              ],
            },
          ],
        };

        final model = MotorcycleDetailModel.fromJson(json);

        // Top-level evidence takes priority
        expect(model.evidence.length, 1);
        expect(model.evidence[0].id, 'ev-top-1');
        expect(model.evidence[0].imageUrl, 'https://example.com/top.jpg');
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
        expect(entity.evidence.first.imageUrl, 'https://example.com/img.jpg');
        expect(entity.permittedBranches.length, 2);
        expect(entity.permittedBranches[0].id, 'branch-1');
        expect(entity.permittedBranches[0].name, 'Taller Norte');
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
        expect(entity.permittedBranches, isEmpty);
      });
    });
  });

  group('PermittedBranchInfoModel', () {
    group('fromJson', () {
      test('should parse all fields from valid JSON', () {
        final json = {'id': 'branch-1', 'name': 'Taller Norte'};

        final model = PermittedBranchInfoModel.fromJson(json);

        expect(model.id, 'branch-1');
        expect(model.name, 'Taller Norte');
      });

      test('should use defaults for missing/null fields', () {
        final model = PermittedBranchInfoModel.fromJson({});

        expect(model.id, '');
        expect(model.name, '');
      });
    });

    group('toEntity', () {
      test('should map all fields correctly', () {
        const model = PermittedBranchInfoModel(
          id: 'branch-1',
          name: 'Taller Norte',
        );

        final entity = model.toEntity();

        expect(entity.id, 'branch-1');
        expect(entity.name, 'Taller Norte');
      });
    });
  });
}
