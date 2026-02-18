import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/repositories/completed_services_repository.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/usecases/update_service_status_usecase.dart';

import 'update_service_status_usecase_test.mocks.dart';

@GenerateMocks([CompletedServicesRepository])
void main() {
  late UpdateServiceStatusUseCase useCase;
  late MockCompletedServicesRepository mockRepository;

  setUpAll(() {
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockRepository = MockCompletedServicesRepository();
    useCase = UpdateServiceStatusUseCase(mockRepository);
  });

  group('UpdateServiceStatusUseCase', () {
    test('call delegates to repository on success', () async {
      when(
        mockRepository.updateServiceStatus(any, any),
      ).thenAnswer((_) async => const Right('Estado actualizado exitosamente'));

      final result = await useCase.call('service-1', 'EN_PROCESO');

      expect(result.isRight, true);
      expect(result.right, 'Estado actualizado exitosamente');
      verify(
        mockRepository.updateServiceStatus('service-1', 'EN_PROCESO'),
      ).called(1);
    });

    test('call delegates to repository on failure', () async {
      when(mockRepository.updateServiceStatus(any, any)).thenAnswer(
        (_) async =>
            Left(ErrorModel(errorCode: 'ERR', message: 'Transición inválida')),
      );

      final result = await useCase.call('service-1', 'INVALID');

      expect(result.isLeft, true);
      expect(result.left.message, 'Transición inválida');
    });
  });
}
