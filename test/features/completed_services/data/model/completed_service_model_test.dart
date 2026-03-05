import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/completed_services/data/model/completed_service_item_model.dart';
import 'package:motogo_frontend/src/features/completed_services/data/model/completed_service_model.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/entities/completed_service_entity.dart';

void main() {
  group('CompletedServiceModel', () {
    final fullJson = <String, dynamic>{
      'id': 'svc-001',
      'branch_id': 'branch-123',
      'branch_name': 'Sede Principal',
      'motorcycle_id': 'moto-456',
      'diagnostic_id': 'diag-789',
      'status': 'FINALIZADO',
      'request_date': '2026-02-15T10:00:00Z',
      'quoted_price': 185000,
      'final_price': 175000,
      'representative_notes': 'Cambio de aceite',
      'services': [
        {
          'id': 'item-1',
          'service_id': 'svc-a',
          'service_name': 'Cambio de aceite',
          'rating': 5,
          'comment': 'Excelente',
          'rated_at': '2026-02-16T12:00:00Z',
        },
        {
          'id': 'item-2',
          'service_id': 'svc-b',
          'service_name': 'Revisión de frenos',
        },
      ],
    };

    group('fromJson', () {
      test('should parse all fields correctly', () {
        final model = CompletedServiceModel.fromJson(fullJson);

        expect(model.id, 'svc-001');
        expect(model.branchId, 'branch-123');
        expect(model.branchName, 'Sede Principal');
        expect(model.motorcycleId, 'moto-456');
        expect(model.diagnosticId, 'diag-789');
        expect(model.status, 'FINALIZADO');
        expect(model.requestDate, DateTime.parse('2026-02-15T10:00:00Z'));
        expect(model.quotedPrice, 185000);
        expect(model.finalPrice, 175000);
        expect(model.representativeNotes, 'Cambio de aceite');
        expect(model.services, hasLength(2));
        expect(model.services[0], isA<CompletedServiceItemModel>());
        expect(model.services[0].serviceId, 'svc-a');
        expect(model.services[0].serviceName, 'Cambio de aceite');
        expect(model.services[0].rating, 5);
        expect(model.services[1].serviceId, 'svc-b');
        expect(model.services[1].rating, isNull);
      });

      test('should handle null optional fields', () {
        final json = <String, dynamic>{
          'id': 'svc-001',
          'branch_id': 'branch-123',
          'motorcycle_id': 'moto-456',
          'status': 'PENDIENTE',
          'request_date': '2026-02-15T10:00:00Z',
        };

        final model = CompletedServiceModel.fromJson(json);

        expect(model.branchName, isNull);
        expect(model.diagnosticId, isNull);
        expect(model.quotedPrice, isNull);
        expect(model.finalPrice, isNull);
        expect(model.representativeNotes, isNull);
        expect(model.services, isEmpty);
      });

      test('should handle empty services list', () {
        final json = <String, dynamic>{
          'id': 'svc-001',
          'branch_id': 'branch-123',
          'motorcycle_id': 'moto-456',
          'status': 'PENDIENTE',
          'request_date': '2026-02-15T10:00:00Z',
          'services': <dynamic>[],
        };

        final model = CompletedServiceModel.fromJson(json);

        expect(model.services, isEmpty);
      });

      test('should handle integer prices via num conversion', () {
        final json = <String, dynamic>{
          'id': 'svc-001',
          'branch_id': 'branch-123',
          'motorcycle_id': 'moto-456',
          'status': 'FINALIZADO',
          'request_date': '2026-02-15T10:00:00Z',
          'quoted_price': 185000,
          'final_price': 175000.5,
        };

        final model = CompletedServiceModel.fromJson(json);

        expect(model.quotedPrice, 185000.0);
        expect(model.finalPrice, 175000.5);
      });
    });

    group('toEntity', () {
      test('should map all fields to entity correctly', () {
        final model = CompletedServiceModel.fromJson(fullJson);
        final entity = model.toEntity();

        expect(entity, isA<CompletedServiceEntity>());
        expect(entity.id, model.id);
        expect(entity.branchId, model.branchId);
        expect(entity.branchName, model.branchName);
        expect(entity.motorcycleId, model.motorcycleId);
        expect(entity.diagnosticId, model.diagnosticId);
        expect(entity.status, model.status);
        expect(entity.requestDate, model.requestDate);
        expect(entity.quotedPrice, model.quotedPrice);
        expect(entity.finalPrice, model.finalPrice);
        expect(entity.representativeNotes, model.representativeNotes);
        expect(entity.services, hasLength(2));
        expect(entity.services[0].serviceId, 'svc-a');
        expect(entity.services[1].serviceId, 'svc-b');
      });

      test('should map null optional fields to entity', () {
        final json = <String, dynamic>{
          'id': 'svc-001',
          'branch_id': 'branch-123',
          'motorcycle_id': 'moto-456',
          'status': 'PENDIENTE',
          'request_date': '2026-02-15T10:00:00Z',
        };

        final entity = CompletedServiceModel.fromJson(json).toEntity();

        expect(entity.branchName, isNull);
        expect(entity.diagnosticId, isNull);
        expect(entity.quotedPrice, isNull);
        expect(entity.finalPrice, isNull);
        expect(entity.representativeNotes, isNull);
        expect(entity.services, isEmpty);
      });
    });
  });
}
