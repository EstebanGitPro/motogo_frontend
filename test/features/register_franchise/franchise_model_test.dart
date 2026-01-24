import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/register_franchise/data/models/franchise_model.dart';
import 'package:motogo_frontend/src/features/register_franchise/domain/entities/franchise_entity.dart';

void main() {
  group('FranchiseModel', () {
    group('fromJson', () {
      test('should create model from complete JSON', () {
        final json = {
          'id': 'franchise-abc123',
          'name': 'MotoService Colombia',
          'description': 'Red de talleres especializados',
          'branch_ids': ['branch-1', 'branch-2', 'branch-3'],
          'branch_count': 3,
        };

        final model = FranchiseModel.fromJson(json);

        expect(model.id, 'franchise-abc123');
        expect(model.name, 'MotoService Colombia');
        expect(model.description, 'Red de talleres especializados');
        expect(model.branchIds, ['branch-1', 'branch-2', 'branch-3']);
        expect(model.branchCount, 3);
      });

      test('should handle missing optional fields', () {
        final json = {'id': 'franchise-xyz', 'name': 'Taller Express'};

        final model = FranchiseModel.fromJson(json);

        expect(model.id, 'franchise-xyz');
        expect(model.name, 'Taller Express');
        expect(model.description, null);
        expect(model.branchIds, isEmpty);
        expect(model.branchCount, null);
      });

      test('should handle null branch_ids as empty list', () {
        final json = {
          'id': 'franchise-001',
          'name': 'Test Franchise',
          'branch_ids': null,
        };

        final model = FranchiseModel.fromJson(json);

        expect(model.branchIds, isEmpty);
      });

      test('should handle empty branch_ids list', () {
        final json = {
          'id': 'franchise-002',
          'name': 'Empty Franchise',
          'branch_ids': <String>[],
        };

        final model = FranchiseModel.fromJson(json);

        expect(model.branchIds, isEmpty);
      });
    });

    group('toJson', () {
      test('should serialize with description when not empty', () {
        const model = FranchiseModel(
          id: 'franchise-123',
          name: 'MotoRed',
          description: 'Una descripción válida',
          branchIds: ['branch-a', 'branch-b'],
        );

        final json = model.toJson();

        expect(json['name'], 'MotoRed');
        expect(json['description'], 'Una descripción válida');
        expect(json['branch_ids'], ['branch-a', 'branch-b']);
        // id is not included in toJson (server generates it)
        expect(json.containsKey('id'), false);
      });

      test('should exclude description when null', () {
        const model = FranchiseModel(
          name: 'Taller Simple',
          branchIds: ['branch-1'],
        );

        final json = model.toJson();

        expect(json.containsKey('description'), false);
      });

      test('should exclude description when empty string', () {
        const model = FranchiseModel(
          name: 'Taller Simple',
          description: '',
          branchIds: ['branch-1'],
        );

        final json = model.toJson();

        expect(json.containsKey('description'), false);
      });
    });

    group('fromEntity', () {
      test('should create model from FranchiseEntity', () {
        const entity = FranchiseEntity(
          id: 'entity-id-123',
          name: 'Entity Franchise',
          description: 'Entity description',
          branchIds: ['b1', 'b2'],
        );

        final model = FranchiseModel.fromEntity(entity);

        expect(model.id, 'entity-id-123');
        expect(model.name, 'Entity Franchise');
        expect(model.description, 'Entity description');
        expect(model.branchIds, ['b1', 'b2']);
        expect(model.branchCount, null); // branchCount not in entity
      });

      test('should handle entity with minimal fields', () {
        const entity = FranchiseEntity(name: 'Minimal');

        final model = FranchiseModel.fromEntity(entity);

        expect(model.id, null);
        expect(model.name, 'Minimal');
        expect(model.description, null);
        expect(model.branchIds, isEmpty);
      });
    });

    group('inheritance', () {
      test('should extend FranchiseEntity', () {
        const model = FranchiseModel(name: 'Test');

        expect(model, isA<FranchiseEntity>());
      });
    });
  });
}
