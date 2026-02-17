import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/completed_services/data/model/status_transition_model.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/repositories/completed_services_repository.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/usecases/get_service_transitions_usecase.dart';

import 'get_service_transitions_usecase_test.mocks.dart';

@GenerateMocks([CompletedServicesRepository])
void main() {
  late GetServiceTransitionsUseCase useCase;
  late MockCompletedServicesRepository mockRepository;

  setUpAll(() {
    provideDummy<Either<ErrorModel, List<StatusTransitionModel>>>(
      const Right([]),
    );
  });

  setUp(() {
    mockRepository = MockCompletedServicesRepository();
    useCase = GetServiceTransitionsUseCase(mockRepository);
  });

  group('GetServiceTransitionsUseCase', () {
    test('call delegates to repository on success', () async {
      final transitions = [
        StatusTransitionModel(
          id: 'trans-1',
          newStatus: 'PENDIENTE',
          createdBy: 'person-1',
          createdAt: DateTime(2026, 2, 16),
        ),
        StatusTransitionModel(
          id: 'trans-2',
          previousStatus: 'PENDIENTE',
          newStatus: 'EN_PROCESO',
          createdBy: 'person-1',
          createdAt: DateTime(2026, 2, 16, 10),
        ),
      ];

      when(
        mockRepository.getServiceTransitions(any),
      ).thenAnswer((_) async => Right(transitions));

      final result = await useCase.call('service-1');

      expect(result.isRight, true);
      expect(result.right, hasLength(2));
      expect(result.right[0].newStatus, 'PENDIENTE');
      expect(result.right[1].previousStatus, 'PENDIENTE');
      verify(mockRepository.getServiceTransitions('service-1')).called(1);
    });

    test('call delegates to repository on failure', () async {
      when(mockRepository.getServiceTransitions(any)).thenAnswer(
        (_) async => Left(
          ErrorModel(errorCode: 'ERR', message: 'Servicio no encontrado'),
        ),
      );

      final result = await useCase.call('service-1');

      expect(result.isLeft, true);
      expect(result.left.message, 'Servicio no encontrado');
    });

    test('call returns empty list when no transitions exist', () async {
      when(
        mockRepository.getServiceTransitions(any),
      ).thenAnswer((_) async => const Right([]));

      final result = await useCase.call('service-1');

      expect(result.isRight, true);
      expect(result.right, isEmpty);
    });
  });
}
