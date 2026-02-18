import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/completed_services/data/model/completed_service_model.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/repositories/completed_services_repository.dart';
import 'package:motogo_frontend/src/features/motorcycle_history/domain/usecases/get_motorcycle_history_usecase.dart';

import 'get_motorcycle_history_usecase_test.mocks.dart';

@GenerateMocks([CompletedServicesRepository])
void main() {
  late GetMotorcycleHistoryUseCase useCase;
  late MockCompletedServicesRepository mockRepository;

  setUpAll(() {
    provideDummy<Either<ErrorModel, List<CompletedServiceModel>>>(
      const Right([]),
    );
  });

  setUp(() {
    mockRepository = MockCompletedServicesRepository();
    useCase = GetMotorcycleHistoryUseCase(mockRepository);
  });

  group('GetMotorcycleHistoryUseCase', () {
    test('should return sorted entities on success', () async {
      final models = [
        CompletedServiceModel(
          id: 'svc-1',
          branchId: 'b-1',
          motorcycleId: 'moto-1',
          status: 'FINALIZADO',
          requestDate: DateTime(2026, 1, 10),
        ),
        CompletedServiceModel(
          id: 'svc-2',
          branchId: 'b-1',
          motorcycleId: 'moto-1',
          status: 'PENDIENTE',
          requestDate: DateTime(2026, 2, 15),
        ),
        CompletedServiceModel(
          id: 'svc-3',
          branchId: 'b-2',
          motorcycleId: 'moto-1',
          status: 'EN_PROCESO',
          requestDate: DateTime(2026, 1, 20),
        ),
      ];

      when(
        mockRepository.getCompletedServicesByMotorcycle('moto-1'),
      ).thenAnswer((_) async => Right(models));

      final result = await useCase.call('moto-1');

      expect(result.isRight, true);
      expect(result.right, hasLength(3));
      // Sorted descending by requestDate
      expect(result.right[0].id, 'svc-2');
      expect(result.right[1].id, 'svc-3');
      expect(result.right[2].id, 'svc-1');
      verify(
        mockRepository.getCompletedServicesByMotorcycle('moto-1'),
      ).called(1);
    });

    test('should return empty list on success with no services', () async {
      when(
        mockRepository.getCompletedServicesByMotorcycle('moto-1'),
      ).thenAnswer((_) async => const Right([]));

      final result = await useCase.call('moto-1');

      expect(result.isRight, true);
      expect(result.right, isEmpty);
    });

    test('should return error when repository fails', () async {
      when(
        mockRepository.getCompletedServicesByMotorcycle('moto-1'),
      ).thenAnswer(
        (_) async =>
            Left(ErrorModel(errorCode: 'ERR', message: 'Network error')),
      );

      final result = await useCase.call('moto-1');

      expect(result.isLeft, true);
      expect(result.left.message, 'Network error');
    });
  });
}
