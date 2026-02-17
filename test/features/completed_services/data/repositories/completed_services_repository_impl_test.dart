import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/completed_services/data/datasources/completed_services_datasource.dart';
import 'package:motogo_frontend/src/features/completed_services/data/model/register_completed_service_model.dart';
import 'package:motogo_frontend/src/features/completed_services/data/model/status_transition_model.dart';
import 'package:motogo_frontend/src/features/completed_services/data/repositories/completed_services_repository_impl.dart';

import 'completed_services_repository_impl_test.mocks.dart';

@GenerateMocks([CompletedServicesDataSource])
void main() {
  late CompletedServicesRepositoryImpl repository;
  late MockCompletedServicesDataSource mockDataSource;

  setUpAll(() {
    provideDummy<Either<ErrorModel, String>>(const Right(''));
    provideDummy<Either<ErrorModel, List<StatusTransitionModel>>>(
      const Right([]),
    );
  });

  setUp(() {
    mockDataSource = MockCompletedServicesDataSource();
    repository = CompletedServicesRepositoryImpl(mockDataSource);
  });

  const testRequest = RegisterCompletedServiceModel(
    branchId: 'branch-1',
    motorcycleId: 'moto-1',
    serviceIds: ['svc-1'],
    quotedPrice: 100000,
    finalPrice: 95000,
    representativeNotes: 'Test notes',
  );

  group('CompletedServicesRepositoryImpl', () {
    test(
      'registerCompletedService delegates to datasource on success',
      () async {
        when(mockDataSource.registerCompletedService(any)).thenAnswer(
          (_) async => const Right('Servicio registrado exitosamente'),
        );

        final result = await repository.registerCompletedService(testRequest);

        expect(result.isRight, true);
        expect(result.right, 'Servicio registrado exitosamente');
        verify(mockDataSource.registerCompletedService(testRequest)).called(1);
      },
    );

    test(
      'registerCompletedService delegates to datasource on failure',
      () async {
        when(mockDataSource.registerCompletedService(any)).thenAnswer(
          (_) async =>
              Left(ErrorModel(errorCode: 'ERR', message: 'Error al registrar')),
        );

        final result = await repository.registerCompletedService(testRequest);

        expect(result.isLeft, true);
        expect(result.left.message, 'Error al registrar');
      },
    );

    // ─── updateServiceStatus ───────────────────────────────────────

    test('updateServiceStatus delegates to datasource on success', () async {
      when(
        mockDataSource.updateServiceStatus(any, any),
      ).thenAnswer((_) async => const Right('Estado actualizado exitosamente'));

      final result = await repository.updateServiceStatus(
        'service-1',
        'EN_PROCESO',
      );

      expect(result.isRight, true);
      expect(result.right, 'Estado actualizado exitosamente');
      verify(
        mockDataSource.updateServiceStatus('service-1', 'EN_PROCESO'),
      ).called(1);
    });

    test('updateServiceStatus delegates to datasource on failure', () async {
      when(mockDataSource.updateServiceStatus(any, any)).thenAnswer(
        (_) async =>
            Left(ErrorModel(errorCode: 'ERR', message: 'Transición inválida')),
      );

      final result = await repository.updateServiceStatus(
        'service-1',
        'INVALID',
      );

      expect(result.isLeft, true);
      expect(result.left.message, 'Transición inválida');
    });

    // ─── getServiceTransitions ─────────────────────────────────────

    test('getServiceTransitions delegates to datasource on success', () async {
      final transitions = [
        StatusTransitionModel(
          id: 'trans-1',
          newStatus: 'PENDIENTE',
          createdBy: 'person-1',
          createdAt: DateTime(2026, 2, 16),
        ),
      ];

      when(
        mockDataSource.getServiceTransitions(any),
      ).thenAnswer((_) async => Right(transitions));

      final result = await repository.getServiceTransitions('service-1');

      expect(result.isRight, true);
      expect(result.right, hasLength(1));
      verify(mockDataSource.getServiceTransitions('service-1')).called(1);
    });

    test('getServiceTransitions delegates to datasource on failure', () async {
      when(mockDataSource.getServiceTransitions(any)).thenAnswer(
        (_) async => Left(
          ErrorModel(errorCode: 'ERR', message: 'Servicio no encontrado'),
        ),
      );

      final result = await repository.getServiceTransitions('service-1');

      expect(result.isLeft, true);
      expect(result.left.message, 'Servicio no encontrado');
    });
  });
}
