import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/completed_services/data/model/register_completed_service_model.dart';

void main() {
  group('RegisterCompletedServiceModel', () {
    test('toJson should include all fields when provided', () {
      const model = RegisterCompletedServiceModel(
        branchId: 'branch-123',
        motorcycleId: 'moto-456',
        serviceIds: ['svc-1', 'svc-2'],
        quotedPrice: 185000,
        finalPrice: 175000,
        representativeNotes: 'Cambio de aceite y revisión general',
      );

      final json = model.toJson();

      expect(json['branch_id'], 'branch-123');
      expect(json['motorcycle_id'], 'moto-456');
      expect(json['service_ids'], ['svc-1', 'svc-2']);
      expect(json['quoted_price'], 185000);
      expect(json['final_price'], 175000);
      expect(
        json['representative_notes'],
        'Cambio de aceite y revisión general',
      );
    });

    test('toJson should omit optional fields when null', () {
      const model = RegisterCompletedServiceModel(
        branchId: 'branch-123',
        motorcycleId: 'moto-456',
        serviceIds: ['svc-1'],
      );

      final json = model.toJson();

      expect(json['branch_id'], 'branch-123');
      expect(json['motorcycle_id'], 'moto-456');
      expect(json['service_ids'], ['svc-1']);
      expect(json.containsKey('quoted_price'), false);
      expect(json.containsKey('final_price'), false);
      expect(json.containsKey('representative_notes'), false);
    });

    test('toJson should omit representative_notes when empty/whitespace', () {
      const model = RegisterCompletedServiceModel(
        branchId: 'branch-123',
        motorcycleId: 'moto-456',
        serviceIds: ['svc-1'],
        representativeNotes: '   ',
      );

      final json = model.toJson();

      expect(json.containsKey('representative_notes'), false);
    });

    test('toJson should trim representative_notes', () {
      const model = RegisterCompletedServiceModel(
        branchId: 'branch-123',
        motorcycleId: 'moto-456',
        serviceIds: ['svc-1'],
        representativeNotes: '  Cambio de aceite  ',
      );

      final json = model.toJson();

      expect(json['representative_notes'], 'Cambio de aceite');
    });

    test('toJson with multiple service_ids', () {
      const model = RegisterCompletedServiceModel(
        branchId: 'b-1',
        motorcycleId: 'm-1',
        serviceIds: ['svc-1', 'svc-2', 'svc-3'],
      );

      final json = model.toJson();
      expect(json['service_ids'], hasLength(3));
    });
  });
}
