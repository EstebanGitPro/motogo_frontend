import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/completed_services/data/model/completed_service_model.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/repositories/completed_services_repository.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/usecases/get_service_history_usecase.dart';

import 'get_service_history_usecase_test.mocks.dart';

@GenerateMocks([CompletedServicesRepository])
void main() {
  late GetServiceHistoryUseCase useCase;
  late MockCompletedServicesRepository mockRepository;

  setUpAll(() {
    provideDummy<Either<ErrorModel, List<CompletedServiceModel>>>(
      const Right([]),
    );
  });

  setUp(() {
    mockRepository = MockCompletedServicesRepository();
    useCase = GetServiceHistoryUseCase(mockRepository);
  });

  CompletedServiceModel _createModel({
    required String id,
    required String branchId,
    required String motorcycleId,
    required DateTime requestDate,
  }) {
    return CompletedServiceModel(
      id: id,
      branchId: branchId,
      motorcycleId: motorcycleId,
      status: 'FINALIZADO',
      requestDate: requestDate,
    );
  }

  group('GetServiceHistoryUseCase', () {
    test('should return empty list when branchIds is empty', () async {
      final result = await useCase.call(motorcycleId: 'moto-1', branchIds: []);

      expect(result.isRight, true);
      expect(result.right, isEmpty);
      verifyNever(mockRepository.getCompletedServicesByBranch(any));
    });

    test('should fetch and combine services from multiple branches', () async {
      final model1 = _createModel(
        id: 'svc-1',
        branchId: 'branch-1',
        motorcycleId: 'moto-1',
        requestDate: DateTime(2026, 2, 10),
      );
      final model2 = _createModel(
        id: 'svc-2',
        branchId: 'branch-2',
        motorcycleId: 'moto-1',
        requestDate: DateTime(2026, 2, 15),
      );

      when(
        mockRepository.getCompletedServicesByBranch('branch-1'),
      ).thenAnswer((_) async => Right([model1]));
      when(
        mockRepository.getCompletedServicesByBranch('branch-2'),
      ).thenAnswer((_) async => Right([model2]));

      final result = await useCase.call(
        motorcycleId: 'moto-1',
        branchIds: ['branch-1', 'branch-2'],
      );

      expect(result.isRight, true);
      expect(result.right, hasLength(2));
      // Should be sorted descending (most recent first)
      expect(result.right[0].id, 'svc-2');
      expect(result.right[1].id, 'svc-1');
    });

    test('should filter services by motorcycleId', () async {
      final matchingModel = _createModel(
        id: 'svc-1',
        branchId: 'branch-1',
        motorcycleId: 'moto-1',
        requestDate: DateTime(2026, 2, 10),
      );
      final otherModel = _createModel(
        id: 'svc-2',
        branchId: 'branch-1',
        motorcycleId: 'moto-other',
        requestDate: DateTime(2026, 2, 15),
      );

      when(
        mockRepository.getCompletedServicesByBranch('branch-1'),
      ).thenAnswer((_) async => Right([matchingModel, otherModel]));

      final result = await useCase.call(
        motorcycleId: 'moto-1',
        branchIds: ['branch-1'],
      );

      expect(result.isRight, true);
      expect(result.right, hasLength(1));
      expect(result.right[0].motorcycleId, 'moto-1');
    });

    test('should skip branches that fail silently', () async {
      final model = _createModel(
        id: 'svc-1',
        branchId: 'branch-2',
        motorcycleId: 'moto-1',
        requestDate: DateTime(2026, 2, 10),
      );

      when(mockRepository.getCompletedServicesByBranch('branch-1')).thenAnswer(
        (_) async =>
            Left(ErrorModel(errorCode: 'ERR', message: 'Network error')),
      );
      when(
        mockRepository.getCompletedServicesByBranch('branch-2'),
      ).thenAnswer((_) async => Right([model]));

      final result = await useCase.call(
        motorcycleId: 'moto-1',
        branchIds: ['branch-1', 'branch-2'],
      );

      expect(result.isRight, true);
      expect(result.right, hasLength(1));
      expect(result.right[0].id, 'svc-1');
    });

    test('should return empty list when all branches fail', () async {
      when(mockRepository.getCompletedServicesByBranch(any)).thenAnswer(
        (_) async =>
            Left(ErrorModel(errorCode: 'ERR', message: 'Network error')),
      );

      final result = await useCase.call(
        motorcycleId: 'moto-1',
        branchIds: ['branch-1', 'branch-2'],
      );

      expect(result.isRight, true);
      expect(result.right, isEmpty);
    });

    test('should sort services by requestDate descending', () async {
      final older = _createModel(
        id: 'svc-old',
        branchId: 'branch-1',
        motorcycleId: 'moto-1',
        requestDate: DateTime(2026, 1, 1),
      );
      final middle = _createModel(
        id: 'svc-mid',
        branchId: 'branch-1',
        motorcycleId: 'moto-1',
        requestDate: DateTime(2026, 2, 1),
      );
      final newer = _createModel(
        id: 'svc-new',
        branchId: 'branch-1',
        motorcycleId: 'moto-1',
        requestDate: DateTime(2026, 3, 1),
      );

      when(
        mockRepository.getCompletedServicesByBranch('branch-1'),
      ).thenAnswer((_) async => Right([older, newer, middle]));

      final result = await useCase.call(
        motorcycleId: 'moto-1',
        branchIds: ['branch-1'],
      );

      expect(result.isRight, true);
      expect(result.right[0].id, 'svc-new');
      expect(result.right[1].id, 'svc-mid');
      expect(result.right[2].id, 'svc-old');
    });
  });
}
