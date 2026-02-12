import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/diagnostic/data/model/diagnostic_model.dart';

void main() {
  group('DiagnosticEvidenceModel', () {
    group('fromJson', () {
      test('should parse all fields from valid JSON', () {
        final json = {
          'id': 'ev-123',
          'image_url': 'https://example.com/evidence.jpg',
          'description': 'Front damage',
          'created_at': '2024-01-15T10:30:00Z',
        };

        final model = DiagnosticEvidenceModel.fromJson(json);

        expect(model.id, 'ev-123');
        expect(model.imageUrl, 'https://example.com/evidence.jpg');
        expect(model.description, 'Front damage');
        expect(model.createdAt, '2024-01-15T10:30:00Z');
      });

      test('should use defaults for missing fields', () {
        final model = DiagnosticEvidenceModel.fromJson(<String, dynamic>{});

        expect(model.id, '');
        expect(model.imageUrl, '');
        expect(model.description, isNull);
        expect(model.createdAt, '');
      });
    });

    group('toEntity', () {
      test('should convert to entity with parsed date', () {
        const model = DiagnosticEvidenceModel(
          id: 'ev-123',
          imageUrl: 'https://example.com/evidence.jpg',
          description: 'Damage',
          createdAt: '2024-01-15T10:30:00Z',
        );

        final entity = model.toEntity();

        expect(entity.id, 'ev-123');
        expect(entity.imageUrl, 'https://example.com/evidence.jpg');
        expect(entity.description, 'Damage');
        expect(entity.createdAt.year, 2024);
        expect(entity.createdAt.month, 1);
        expect(entity.createdAt.day, 15);
      });

      test('should fallback to DateTime.now for invalid date', () {
        const model = DiagnosticEvidenceModel(
          id: 'ev-123',
          imageUrl: 'https://example.com/evidence.jpg',
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

  group('DiagnosticModel', () {
    group('fromJson (wrapper format)', () {
      test('should parse from data wrapper', () {
        final json = {
          'data': <String, dynamic>{
            'id': 'diag-123',
            'motorcycle_id': 'moto-456',
            'branch_id': 'branch-789',
            'problem_description': 'Ruido en motor',
            'possible_solution': 'Cambiar correa',
            'date': '2024-01-15',
            'sent_via_whatsapp': true,
            'evidence': [
              <String, dynamic>{
                'id': 'ev-1',
                'image_url': 'https://example.com/img.jpg',
                'created_at': '2024-01-15',
              },
            ],
          },
        };

        final model = DiagnosticModel.fromJson(json);

        expect(model.id, 'diag-123');
        expect(model.motorcycleId, 'moto-456');
        expect(model.branchId, 'branch-789');
        expect(model.problemDescription, 'Ruido en motor');
        expect(model.possibleSolution, 'Cambiar correa');
        expect(model.date, '2024-01-15');
        expect(model.sentViaWhatsapp, isTrue);
        expect(model.evidence.length, 1);
      });

      test('should parse without data wrapper (flat format)', () {
        final json = {
          'id': 'diag-123',
          'motorcycle_id': 'moto-456',
          'problem_description': 'Frenos desgastados',
          'date': '2024-02-01',
        };

        final model = DiagnosticModel.fromJson(json);

        expect(model.id, 'diag-123');
        expect(model.problemDescription, 'Frenos desgastados');
        expect(model.branchId, isNull);
        expect(model.possibleSolution, isNull);
        expect(model.sentViaWhatsapp, isFalse);
        expect(model.evidence, isEmpty);
      });

      test('should use defaults for missing fields', () {
        final model = DiagnosticModel.fromJson(<String, dynamic>{});

        expect(model.id, '');
        expect(model.motorcycleId, '');
        expect(model.branchId, isNull);
        expect(model.problemDescription, '');
        expect(model.possibleSolution, isNull);
        expect(model.date, '');
        expect(model.sentViaWhatsapp, isFalse);
        expect(model.evidence, isEmpty);
      });
    });

    group('fromDataJson', () {
      test('should parse from flat JSON', () {
        final json = {
          'id': 'diag-abc',
          'motorcycle_id': 'moto-xyz',
          'branch_id': 'branch-123',
          'problem_description': 'Aceite con fugas',
          'possible_solution': 'Cambiar empaque',
          'date': '2024-03-10',
          'sent_via_whatsapp': false,
          'evidence': <Map<String, dynamic>>[],
        };

        final model = DiagnosticModel.fromDataJson(json);

        expect(model.id, 'diag-abc');
        expect(model.motorcycleId, 'moto-xyz');
        expect(model.branchId, 'branch-123');
        expect(model.problemDescription, 'Aceite con fugas');
        expect(model.possibleSolution, 'Cambiar empaque');
        expect(model.sentViaWhatsapp, isFalse);
      });

      test('should handle null evidence in fromDataJson', () {
        final json = {
          'id': 'diag-1',
          'motorcycle_id': 'moto-1',
          'problem_description': 'Test',
          'date': '2024-01-01',
          'evidence': null,
        };

        final model = DiagnosticModel.fromDataJson(json);

        expect(model.evidence, isEmpty);
      });

      test('should handle non-list evidence in fromDataJson', () {
        final json = {
          'id': 'diag-1',
          'motorcycle_id': 'moto-1',
          'problem_description': 'Test',
          'date': '2024-01-01',
          'evidence': 'not-a-list',
        };

        final model = DiagnosticModel.fromDataJson(json);

        expect(model.evidence, isEmpty);
      });
    });

    group('toEntity', () {
      test('should convert all fields to entity', () {
        const model = DiagnosticModel(
          id: 'diag-123',
          motorcycleId: 'moto-456',
          branchId: 'branch-789',
          problemDescription: 'Motor ruidoso',
          possibleSolution: 'Cambiar correa',
          date: '2024-01-15',
          sentViaWhatsapp: true,
          evidence: [
            DiagnosticEvidenceModel(
              id: 'ev-1',
              imageUrl: 'https://example.com/img.jpg',
              createdAt: '2024-01-15',
            ),
          ],
        );

        final entity = model.toEntity();

        expect(entity.id, 'diag-123');
        expect(entity.motorcycleId, 'moto-456');
        expect(entity.branchId, 'branch-789');
        expect(entity.problemDescription, 'Motor ruidoso');
        expect(entity.possibleSolution, 'Cambiar correa');
        expect(entity.date.year, 2024);
        expect(entity.sentViaWhatsapp, isTrue);
        expect(entity.evidence.length, 1);
      });

      test('should fallback to DateTime.now for invalid date', () {
        const model = DiagnosticModel(
          id: 'diag-1',
          motorcycleId: 'moto-1',
          problemDescription: 'Test',
          date: 'invalid',
        );

        final before = DateTime.now();
        final entity = model.toEntity();
        final after = DateTime.now();

        expect(
          entity.date.isAfter(before.subtract(const Duration(seconds: 1))),
          isTrue,
        );
        expect(
          entity.date.isBefore(after.add(const Duration(seconds: 1))),
          isTrue,
        );
      });
    });

    group('toMap', () {
      test('should create map with problem_description', () {
        const model = DiagnosticModel(
          id: 'diag-1',
          motorcycleId: 'moto-1',
          branchId: 'branch-1',
          problemDescription: 'Issue',
          date: '2024-01-01',
        );

        final map = model.toMap();

        expect(map['problem_description'], 'Issue');
        expect(map['branch_id'], 'branch-1');
      });

      test('should exclude branch_id when null', () {
        const model = DiagnosticModel(
          id: 'diag-1',
          motorcycleId: 'moto-1',
          problemDescription: 'Issue',
          date: '2024-01-01',
        );

        final map = model.toMap();

        expect(map.containsKey('branch_id'), isFalse);
      });
    });
  });
}
