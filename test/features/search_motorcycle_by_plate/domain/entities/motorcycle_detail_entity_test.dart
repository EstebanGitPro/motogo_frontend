import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/diagnostic/domain/entity/diagnostic_entity.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/domain/entities/motorcycle_evidence_entity.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/entities/motorcycle_detail_entity.dart';

void main() {
  group('MotorcycleReferenceInfoEntity', () {
    group('constructor', () {
      test('should create instance with all required fields', () {
        const entity = MotorcycleReferenceInfoEntity(
          brandName: 'Yamaha',
          model: 'MT-07',
          category: 'Naked',
          engineDisplacementCc: 689,
        );

        expect(entity.brandName, 'Yamaha');
        expect(entity.model, 'MT-07');
        expect(entity.category, 'Naked');
        expect(entity.engineDisplacementCc, 689);
      });
    });

    group('Equatable', () {
      test('should be equal when all properties match', () {
        const entity1 = MotorcycleReferenceInfoEntity(
          brandName: 'Yamaha',
          model: 'MT-07',
          category: 'Naked',
          engineDisplacementCc: 689,
        );
        const entity2 = MotorcycleReferenceInfoEntity(
          brandName: 'Yamaha',
          model: 'MT-07',
          category: 'Naked',
          engineDisplacementCc: 689,
        );

        expect(entity1, equals(entity2));
        expect(entity1.hashCode, equals(entity2.hashCode));
      });

      test('should not be equal when brandName differs', () {
        const entity1 = MotorcycleReferenceInfoEntity(
          brandName: 'Yamaha',
          model: 'MT-07',
          category: 'Naked',
          engineDisplacementCc: 689,
        );
        const entity2 = MotorcycleReferenceInfoEntity(
          brandName: 'Honda',
          model: 'MT-07',
          category: 'Naked',
          engineDisplacementCc: 689,
        );

        expect(entity1, isNot(equals(entity2)));
      });

      test('props should include all fields', () {
        const entity = MotorcycleReferenceInfoEntity(
          brandName: 'Yamaha',
          model: 'MT-07',
          category: 'Naked',
          engineDisplacementCc: 689,
        );

        expect(entity.props.length, 4);
        expect(entity.props, contains('Yamaha'));
        expect(entity.props, contains('MT-07'));
        expect(entity.props, contains('Naked'));
        expect(entity.props, contains(689));
      });
    });
  });

  group('MotorcycleDetailEntity', () {
    const testReference = MotorcycleReferenceInfoEntity(
      brandName: 'Yamaha',
      model: 'MT-07',
      category: 'Naked',
      engineDisplacementCc: 689,
    );

    group('constructor', () {
      test('should create instance with required fields', () {
        const entity = MotorcycleDetailEntity(
          id: 'moto-123',
          licensePlate: 'ABC12D',
          year: 2023,
          currentMileage: 5000,
          reference: testReference,
        );

        expect(entity.id, 'moto-123');
        expect(entity.licensePlate, 'ABC12D');
        expect(entity.year, 2023);
        expect(entity.currentMileage, 5000);
        expect(entity.profileImageUrl, isNull);
        expect(entity.reference, testReference);
        expect(entity.diagnostics, isEmpty);
        expect(entity.evidence, isEmpty);
      });

      test('should create instance with all optional fields', () {
        final diagnostic = DiagnosticEntity(
          id: 'diag-1',
          motorcycleId: 'moto-123',
          problemDescription: 'Ruido extraño',
          date: DateTime(2024, 1, 15),
        );
        final evidence = MotorcycleEvidenceEntity(
          id: 'ev-1',
          motorcycleId: 'moto-123',
          imageUrl: 'https://example.com/img.jpg',
          createdAt: DateTime(2024, 1, 15),
        );

        final entity = MotorcycleDetailEntity(
          id: 'moto-123',
          licensePlate: 'ABC12D',
          year: 2023,
          currentMileage: 5000,
          profileImageUrl: 'https://example.com/profile.jpg',
          reference: testReference,
          diagnostics: [diagnostic],
          evidence: [evidence],
        );

        expect(entity.profileImageUrl, 'https://example.com/profile.jpg');
        expect(entity.diagnostics.length, 1);
        expect(entity.evidence.length, 1);
      });
    });

    group('Equatable', () {
      test('should be equal when all properties match', () {
        const entity1 = MotorcycleDetailEntity(
          id: 'moto-123',
          licensePlate: 'ABC12D',
          year: 2023,
          currentMileage: 5000,
          reference: testReference,
        );
        const entity2 = MotorcycleDetailEntity(
          id: 'moto-123',
          licensePlate: 'ABC12D',
          year: 2023,
          currentMileage: 5000,
          reference: testReference,
        );

        expect(entity1, equals(entity2));
        expect(entity1.hashCode, equals(entity2.hashCode));
      });

      test('should not be equal when id differs', () {
        const entity1 = MotorcycleDetailEntity(
          id: 'moto-123',
          licensePlate: 'ABC12D',
          year: 2023,
          currentMileage: 5000,
          reference: testReference,
        );
        const entity2 = MotorcycleDetailEntity(
          id: 'moto-456',
          licensePlate: 'ABC12D',
          year: 2023,
          currentMileage: 5000,
          reference: testReference,
        );

        expect(entity1, isNot(equals(entity2)));
      });

      test('should not be equal when licensePlate differs', () {
        const entity1 = MotorcycleDetailEntity(
          id: 'moto-123',
          licensePlate: 'ABC12D',
          year: 2023,
          currentMileage: 5000,
          reference: testReference,
        );
        const entity2 = MotorcycleDetailEntity(
          id: 'moto-123',
          licensePlate: 'XYZ98F',
          year: 2023,
          currentMileage: 5000,
          reference: testReference,
        );

        expect(entity1, isNot(equals(entity2)));
      });

      test('props should include all fields', () {
        const entity = MotorcycleDetailEntity(
          id: 'moto-123',
          licensePlate: 'ABC12D',
          year: 2023,
          currentMileage: 5000,
          profileImageUrl: 'https://example.com/profile.jpg',
          reference: testReference,
        );

        expect(entity.props.length, 8);
        expect(entity.props, contains('moto-123'));
        expect(entity.props, contains('ABC12D'));
        expect(entity.props, contains(2023));
        expect(entity.props, contains(5000));
        expect(entity.props, contains('https://example.com/profile.jpg'));
        expect(entity.props, contains(testReference));
      });
    });
  });
}
