import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/motorcycle_references/data/models/motorcycle_reference_model.dart';
import 'package:motogo_frontend/src/features/motorcycle_references/domain/entities/motorcycle_reference_entity.dart';

void main() {
  group('MotorcycleReferenceModel', () {
    group('fromJson', () {
      test('should create model from complete JSON', () {
        final json = {
          'id': 'ref-123',
          'brand_id': 'brand-456',
          'brand_name': 'Yamaha',
          'model': 'MT-07',
          'category': 'Naked',
          'engine_displacement_cc': 689,
        };

        final model = MotorcycleReferenceModel.fromJson(json);

        expect(model.id, 'ref-123');
        expect(model.brandId, 'brand-456');
        expect(model.brandName, 'Yamaha');
        expect(model.model, 'MT-07');
        expect(model.category, 'Naked');
        expect(model.engineDisplacementCc, 689);
      });

      test('should handle missing optional fields', () {
        final json = {
          'id': 'ref-123',
          'brand_id': 'brand-456',
          'brand_name': 'Honda',
          'model': 'CB500F',
        };

        final model = MotorcycleReferenceModel.fromJson(json);

        expect(model.id, 'ref-123');
        expect(model.brandName, 'Honda');
        expect(model.model, 'CB500F');
        expect(model.category, isNull);
        expect(model.engineDisplacementCc, isNull);
      });

      test('should handle null values gracefully', () {
        final json = <String, dynamic>{
          'id': null,
          'brand_id': null,
          'brand_name': null,
          'model': null,
          'category': null,
          'engine_displacement_cc': null,
        };

        final model = MotorcycleReferenceModel.fromJson(json);

        expect(model.id, '');
        expect(model.brandId, '');
        expect(model.brandName, '');
        expect(model.model, '');
        expect(model.category, isNull);
        expect(model.engineDisplacementCc, isNull);
      });

      test('should handle empty JSON', () {
        final json = <String, dynamic>{};

        final model = MotorcycleReferenceModel.fromJson(json);

        expect(model.id, '');
        expect(model.brandId, '');
        expect(model.brandName, '');
        expect(model.model, '');
      });
    });

    group('toEntity', () {
      test('should convert model to entity with all fields', () {
        const model = MotorcycleReferenceModel(
          id: 'ref-123',
          brandId: 'brand-456',
          brandName: 'Suzuki',
          model: 'GSX-R600',
          category: 'Deportiva',
          engineDisplacementCc: 599,
        );

        final entity = model.toEntity();

        expect(entity, isA<MotorcycleReferenceEntity>());
        expect(entity.id, 'ref-123');
        expect(entity.brandId, 'brand-456');
        expect(entity.brandName, 'Suzuki');
        expect(entity.model, 'GSX-R600');
        expect(entity.category, 'Deportiva');
        expect(entity.engineDisplacementCc, 599);
      });

      test('should convert model to entity with nullable fields', () {
        const model = MotorcycleReferenceModel(
          id: 'ref-123',
          brandId: 'brand-456',
          brandName: 'Kawasaki',
          model: 'Ninja 400',
        );

        final entity = model.toEntity();

        expect(entity.category, isNull);
        expect(entity.engineDisplacementCc, isNull);
      });
    });

    group('round-trip', () {
      test('should maintain data integrity through fromJson -> toEntity', () {
        final json = {
          'id': 'ref-123',
          'brand_id': 'brand-456',
          'brand_name': 'Yamaha',
          'model': 'XSR700',
          'category': 'Sport Heritage',
          'engine_displacement_cc': 689,
        };

        final model = MotorcycleReferenceModel.fromJson(json);
        final entity = model.toEntity();

        expect(entity.id, json['id']);
        expect(entity.brandId, json['brand_id']);
        expect(entity.brandName, json['brand_name']);
        expect(entity.model, json['model']);
        expect(entity.category, json['category']);
        expect(entity.engineDisplacementCc, json['engine_displacement_cc']);
      });
    });
  });
}
