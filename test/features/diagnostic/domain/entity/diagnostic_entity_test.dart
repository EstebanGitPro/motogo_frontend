import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/diagnostic/domain/entity/diagnostic_entity.dart';

void main() {
  group('DiagnosticEvidenceEntity', () {
    final testDate = DateTime(2024, 1, 15, 10, 30);

    group('constructor', () {
      test('should create instance with required fields', () {
        final entity = DiagnosticEvidenceEntity(
          id: 'ev-123',
          imageUrl: 'https://example.com/img.jpg',
          createdAt: testDate,
        );

        expect(entity.id, 'ev-123');
        expect(entity.imageUrl, 'https://example.com/img.jpg');
        expect(entity.description, isNull);
        expect(entity.createdAt, testDate);
      });

      test('should create instance with optional description', () {
        final entity = DiagnosticEvidenceEntity(
          id: 'ev-123',
          imageUrl: 'https://example.com/img.jpg',
          description: 'Front view',
          createdAt: testDate,
        );

        expect(entity.description, 'Front view');
      });
    });

    group('Equatable', () {
      test('should be equal when all properties match', () {
        final entity1 = DiagnosticEvidenceEntity(
          id: 'ev-123',
          imageUrl: 'https://example.com/img.jpg',
          description: 'Desc',
          createdAt: testDate,
        );
        final entity2 = DiagnosticEvidenceEntity(
          id: 'ev-123',
          imageUrl: 'https://example.com/img.jpg',
          description: 'Desc',
          createdAt: testDate,
        );

        expect(entity1, equals(entity2));
      });

      test('should not be equal when id differs', () {
        final entity1 = DiagnosticEvidenceEntity(
          id: 'ev-1',
          imageUrl: 'https://example.com/img.jpg',
          createdAt: testDate,
        );
        final entity2 = DiagnosticEvidenceEntity(
          id: 'ev-2',
          imageUrl: 'https://example.com/img.jpg',
          createdAt: testDate,
        );

        expect(entity1, isNot(equals(entity2)));
      });

      test('props should include all fields', () {
        final entity = DiagnosticEvidenceEntity(
          id: 'ev-123',
          imageUrl: 'https://example.com/img.jpg',
          description: 'Desc',
          createdAt: testDate,
        );

        expect(entity.props.length, 4);
      });
    });
  });

  group('DiagnosticEntity', () {
    final testDate = DateTime(2024, 1, 15);

    group('constructor', () {
      test('should create instance with required fields', () {
        final entity = DiagnosticEntity(
          id: 'diag-123',
          motorcycleId: 'moto-456',
          problemDescription: 'Ruido extraño',
          date: testDate,
        );

        expect(entity.id, 'diag-123');
        expect(entity.motorcycleId, 'moto-456');
        expect(entity.branchId, isNull);
        expect(entity.problemDescription, 'Ruido extraño');
        expect(entity.possibleSolution, isNull);
        expect(entity.date, testDate);
        expect(entity.evidence, isEmpty);
      });

      test('should create instance with all optional fields', () {
        final evidenceDate = DateTime(2024, 1, 15, 10, 30);
        final entity = DiagnosticEntity(
          id: 'diag-123',
          motorcycleId: 'moto-456',
          branchId: 'branch-789',
          problemDescription: 'Ruido extraño',
          possibleSolution: 'Cambiar correa',
          date: testDate,
          evidence: [
            DiagnosticEvidenceEntity(
              id: 'ev-1',
              imageUrl: 'https://example.com/img.jpg',
              createdAt: evidenceDate,
            ),
          ],
        );

        expect(entity.branchId, 'branch-789');
        expect(entity.possibleSolution, 'Cambiar correa');
        expect(entity.evidence.length, 1);
      });
    });

    group('Equatable', () {
      test('should be equal when all properties match', () {
        final entity1 = DiagnosticEntity(
          id: 'diag-123',
          motorcycleId: 'moto-456',
          problemDescription: 'Issue',
          date: testDate,
        );
        final entity2 = DiagnosticEntity(
          id: 'diag-123',
          motorcycleId: 'moto-456',
          problemDescription: 'Issue',
          date: testDate,
        );

        expect(entity1, equals(entity2));
        expect(entity1.hashCode, equals(entity2.hashCode));
      });

      test('should not be equal when id differs', () {
        final entity1 = DiagnosticEntity(
          id: 'diag-1',
          motorcycleId: 'moto-456',
          problemDescription: 'Issue',
          date: testDate,
        );
        final entity2 = DiagnosticEntity(
          id: 'diag-2',
          motorcycleId: 'moto-456',
          problemDescription: 'Issue',
          date: testDate,
        );

        expect(entity1, isNot(equals(entity2)));
      });

      test('props should include all fields', () {
        final entity = DiagnosticEntity(
          id: 'diag-123',
          motorcycleId: 'moto-456',
          branchId: 'branch-789',
          problemDescription: 'Issue',
          possibleSolution: 'Fix',
          date: testDate,
          evidence: const [],
        );

        expect(entity.props.length, 7);
        expect(entity.props, contains('diag-123'));
        expect(entity.props, contains('moto-456'));
        expect(entity.props, contains('branch-789'));
        expect(entity.props, contains('Issue'));
        expect(entity.props, contains('Fix'));
        expect(entity.props, contains(testDate));
      });
    });
  });
}
