import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/data/models/motorcycle_model.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/entities/motorcycle_entity.dart';

void main() {
  group('MotorcycleModel', () {
    group('fromJson', () {
      test('should create model from complete JSON', () {
        final json = {
          'id': 'moto-123',
          'license_plate': 'ABC12D',
          'reference_id': 'ref-456',
          'year': 2023,
          'current_mileage': 15000,
          'owner_notes': 'Mi moto',
        };

        final model = MotorcycleModel.fromJson(json);

        expect(model.id, 'moto-123');
        expect(model.licensePlate, 'ABC12D');
        expect(model.referenceId, 'ref-456');
        expect(model.year, 2023);
        expect(model.currentMileage, 15000);
        expect(model.ownerNotes, 'Mi moto');
      });

      test('should handle missing optional fields', () {
        final json = {'license_plate': 'XYZ123'};

        final model = MotorcycleModel.fromJson(json);

        expect(model.licensePlate, 'XYZ123');
        expect(model.id, isNull);
        expect(model.referenceId, isNull);
        expect(model.year, isNull);
        expect(model.currentMileage, isNull);
        expect(model.ownerNotes, isNull);
      });

      test('should handle null license_plate', () {
        final json = <String, dynamic>{};

        final model = MotorcycleModel.fromJson(json);

        expect(model.licensePlate, '');
      });
    });

    group('toJson', () {
      test('should convert model to JSON with all fields', () {
        const model = MotorcycleModel(
          licensePlate: 'ABC12D',
          referenceId: 'ref-456',
          year: 2023,
          currentMileage: 15000,
          ownerNotes: 'Notas del propietario',
        );

        final json = model.toJson();

        expect(json['license_plate'], 'ABC12D');
        expect(json['reference_id'], 'ref-456');
        expect(json['year'], 2023);
        expect(json['current_mileage'], 15000);
        expect(json['owner_notes'], 'Notas del propietario');
      });

      test('should omit null fields', () {
        const model = MotorcycleModel(licensePlate: 'XYZ123');

        final json = model.toJson();

        expect(json.containsKey('license_plate'), isTrue);
        expect(json.containsKey('reference_id'), isFalse);
        expect(json.containsKey('year'), isFalse);
        expect(json.containsKey('current_mileage'), isFalse);
        expect(json.containsKey('owner_notes'), isFalse);
      });

      test('should omit empty owner_notes', () {
        const model = MotorcycleModel(licensePlate: 'ABC12D', ownerNotes: '');

        final json = model.toJson();

        expect(json.containsKey('owner_notes'), isFalse);
      });

      test('should include reference_id when present', () {
        const model = MotorcycleModel(
          licensePlate: 'ABC12D',
          referenceId: 'ref-789',
        );

        final json = model.toJson();

        expect(json['reference_id'], 'ref-789');
      });
    });

    group('fromEntity', () {
      test('should create model from entity', () {
        const entity = MotorcycleEntity(
          id: 'moto-123',
          licensePlate: 'ABC12D',
          referenceId: 'ref-456',
          year: 2023,
          currentMileage: 15000,
          ownerNotes: 'Notas',
        );

        final model = MotorcycleModel.fromEntity(entity);

        expect(model.id, entity.id);
        expect(model.licensePlate, entity.licensePlate);
        expect(model.referenceId, entity.referenceId);
        expect(model.year, entity.year);
        expect(model.currentMileage, entity.currentMileage);
        expect(model.ownerNotes, entity.ownerNotes);
      });
    });

    group('toEntity', () {
      test('should convert model to entity', () {
        const model = MotorcycleModel(
          id: 'moto-123',
          licensePlate: 'ABC12D',
          referenceId: 'ref-456',
          year: 2023,
        );

        final entity = model.toEntity();

        expect(entity, isA<MotorcycleEntity>());
        expect(entity.id, model.id);
        expect(entity.licensePlate, model.licensePlate);
        expect(entity.referenceId, model.referenceId);
        expect(entity.year, model.year);
      });
    });

    group('copyWith', () {
      test('should copy with updated referenceId', () {
        const original = MotorcycleModel(
          licensePlate: 'ABC12D',
          referenceId: 'old-ref',
        );

        final copy = original.copyWith(referenceId: 'new-ref');

        expect(copy.referenceId, 'new-ref');
        expect(copy.licensePlate, 'ABC12D');
      });
    });

    group('round-trip', () {
      test('should maintain data integrity through JSON round-trip', () {
        final originalJson = {
          'id': 'moto-123',
          'license_plate': 'ABC12D',
          'reference_id': 'ref-456',
          'year': 2023,
          'current_mileage': 15000,
          'owner_notes': 'Notas de prueba',
        };

        final model = MotorcycleModel.fromJson(originalJson);
        final resultJson = model.toJson();

        expect(resultJson['license_plate'], originalJson['license_plate']);
        expect(resultJson['reference_id'], originalJson['reference_id']);
        expect(resultJson['year'], originalJson['year']);
        expect(resultJson['current_mileage'], originalJson['current_mileage']);
        expect(resultJson['owner_notes'], originalJson['owner_notes']);
      });
    });
  });
}
