import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/completed_services/data/model/register_completed_service_model.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/repositories/completed_services_repository.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/usecases/register_completed_service_usecase.dart';

import 'register_completed_service_usecase_test.mocks.dart';

@GenerateMocks([CompletedServicesRepository])
void main() {
  late RegisterCompletedServiceUseCase useCase;
  late MockCompletedServicesRepository mockRepository;

  setUpAll(() {
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockRepository = MockCompletedServicesRepository();
    useCase = RegisterCompletedServiceUseCase(mockRepository);
  });

  const testRequest = RegisterCompletedServiceModel(
    branchId: 'branch-1',
    motorcycleId: 'moto-1',
    serviceIds: ['svc-1', 'svc-2'],
    quotedPrice: 185000,
    finalPrice: 175000,
    representativeNotes: 'Cambio de aceite',
  );

  group('RegisterCompletedServiceUseCase', () {
    test('call delegates to repository on success', () async {
      when(mockRepository.registerCompletedService(any)).thenAnswer(
        (_) async => const Right('Servicio registrado exitosamente'),
      );

      final result = await useCase(testRequest);

      expect(result.isRight, true);
      expect(result.right, 'Servicio registrado exitosamente');
      verify(mockRepository.registerCompletedService(testRequest)).called(1);
    });

    test('call delegates to repository on failure', () async {
      when(mockRepository.registerCompletedService(any)).thenAnswer(
        (_) async =>
            Left(ErrorModel(errorCode: 'ERR', message: 'Error al registrar')),
      );

      final result = await useCase(testRequest);

      expect(result.isLeft, true);
      expect(result.left.message, 'Error al registrar');
    });
  });
}
