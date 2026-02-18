import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/diagnostic_permission/data/model/diagnostic_permission_model.dart';

void main() {
  group('DiagnosticPermissionModel', () {
    group('fromJson', () {
      test('should create model from flat JSON', () {
        final json = {
          'id': 'perm-1',
          'motorcycle_id': 'moto-1',
          'branch_id': 'branch-1',
          'branch_name': 'Taller Central',
          'active': true,
          'granted_at': '2026-01-15T10:00:00Z',
        };

        final model = DiagnosticPermissionModel.fromJson(json);

        expect(model.id, 'perm-1');
        expect(model.motorcycleId, 'moto-1');
        expect(model.branchId, 'branch-1');
        expect(model.branchName, 'Taller Central');
        expect(model.active, isTrue);
        expect(model.grantedAt, '2026-01-15T10:00:00Z');
      });

      test('should create model from nested data JSON', () {
        final json = {
          'data': {
            'id': 'perm-2',
            'motorcycle_id': 'moto-2',
            'branch_id': 'branch-2',
            'active': false,
            'granted_at': '2026-02-10',
          },
        };

        final model = DiagnosticPermissionModel.fromJson(json);

        expect(model.id, 'perm-2');
        expect(model.active, isFalse);
      });

      test('should handle null values with defaults', () {
        final json = <String, dynamic>{};

        final model = DiagnosticPermissionModel.fromJson(json);

        expect(model.id, '');
        expect(model.motorcycleId, '');
        expect(model.branchId, '');
        expect(model.branchName, isNull);
        expect(model.active, isTrue);
        expect(model.grantedAt, '');
      });
    });

    group('fromDataJson', () {
      test('should create model from flat json directly', () {
        final json = {
          'id': 'perm-3',
          'motorcycle_id': 'moto-3',
          'branch_id': 'branch-3',
          'branch_name': 'Sucursal Norte',
          'active': true,
          'granted_at': '2026-03-01',
        };

        final model = DiagnosticPermissionModel.fromDataJson(json);

        expect(model.id, 'perm-3');
        expect(model.branchName, 'Sucursal Norte');
      });

      test('should handle missing values with defaults', () {
        final json = <String, dynamic>{};

        final model = DiagnosticPermissionModel.fromDataJson(json);

        expect(model.id, '');
        expect(model.motorcycleId, '');
        expect(model.branchId, '');
        expect(model.active, isTrue);
      });
    });

    group('toEntity', () {
      test('should convert model to entity', () {
        const model = DiagnosticPermissionModel(
          id: 'perm-1',
          motorcycleId: 'moto-1',
          branchId: 'branch-1',
          branchName: 'Taller Central',
          active: true,
          grantedAt: '2026-01-15T10:00:00Z',
        );

        final entity = model.toEntity();

        expect(entity.id, 'perm-1');
        expect(entity.motorcycleId, 'moto-1');
        expect(entity.branchId, 'branch-1');
        expect(entity.branchName, 'Taller Central');
        expect(entity.active, isTrue);
        expect(entity.grantedAt, isNotNull);
      });

      test('should handle invalid date in grantedAt', () {
        const model = DiagnosticPermissionModel(
          id: 'perm-1',
          motorcycleId: 'moto-1',
          branchId: 'branch-1',
          grantedAt: 'not-a-date',
        );

        final entity = model.toEntity();

        // Falls back to DateTime.now()
        expect(entity.grantedAt, isNotNull);
      });
    });
  });
}
