import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/completed_services/data/model/status_transition_model.dart';

void main() {
  group('StatusTransitionModel', () {
    group('fromJson', () {
      test('should parse all fields correctly', () {
        final json = {
          'id': 'trans-1',
          'previous_status': 'PENDIENTE',
          'new_status': 'EN_PROCESO',
          'created_by': 'person-1',
          'created_at': '2026-02-16T10:30:00Z',
        };

        final model = StatusTransitionModel.fromJson(json);

        expect(model.id, 'trans-1');
        expect(model.previousStatus, 'PENDIENTE');
        expect(model.newStatus, 'EN_PROCESO');
        expect(model.createdBy, 'person-1');
        expect(model.createdAt, DateTime.parse('2026-02-16T10:30:00Z'));
      });

      test('should handle null previous_status', () {
        final json = {
          'id': 'trans-1',
          'previous_status': null,
          'new_status': 'PENDIENTE',
          'created_by': 'person-1',
          'created_at': '2026-02-16T10:30:00Z',
        };

        final model = StatusTransitionModel.fromJson(json);

        expect(model.previousStatus, isNull);
        expect(model.newStatus, 'PENDIENTE');
      });

      test('should handle missing previous_status key', () {
        final json = {
          'id': 'trans-1',
          'new_status': 'PENDIENTE',
          'created_by': 'person-1',
          'created_at': '2026-02-16T10:30:00Z',
        };

        final model = StatusTransitionModel.fromJson(json);

        expect(model.previousStatus, isNull);
      });
    });

    group('toEntity', () {
      test('should convert to StatusTransitionEntity correctly', () {
        final model = StatusTransitionModel(
          id: 'trans-1',
          previousStatus: 'PENDIENTE',
          newStatus: 'EN_PROCESO',
          createdBy: 'person-1',
          createdAt: DateTime(2026, 2, 16, 10, 30),
        );

        final entity = model.toEntity();

        expect(entity.id, 'trans-1');
        expect(entity.previousStatus, 'PENDIENTE');
        expect(entity.newStatus, 'EN_PROCESO');
        expect(entity.createdBy, 'person-1');
        expect(entity.createdAt, DateTime(2026, 2, 16, 10, 30));
      });

      test('should convert null previousStatus correctly', () {
        final model = StatusTransitionModel(
          id: 'trans-1',
          newStatus: 'PENDIENTE',
          createdBy: 'person-1',
          createdAt: DateTime(2026, 2, 16),
        );

        final entity = model.toEntity();

        expect(entity.previousStatus, isNull);
        expect(entity.newStatus, 'PENDIENTE');
      });
    });

    group('constructor', () {
      test('should create const instance', () {
        final model = StatusTransitionModel(
          id: 'trans-1',
          previousStatus: 'EN_PROCESO',
          newStatus: 'FINALIZADO',
          createdBy: 'person-1',
          createdAt: DateTime(2026, 2, 16),
        );

        expect(model.id, 'trans-1');
        expect(model.previousStatus, 'EN_PROCESO');
        expect(model.newStatus, 'FINALIZADO');
      });
    });
  });
}
