import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/repositories/completed_services_repository.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/usecases/delete_completed_service_usecase.dart';

import 'delete_completed_service_usecase_test.mocks.dart';

@GenerateMocks([CompletedServicesRepository])
void main() {
  late DeleteCompletedServiceUseCase useCase;
  late MockCompletedServicesRepository mockRepository;

  setUpAll(() {
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockRepository = MockCompletedServicesRepository();
    useCase = DeleteCompletedServiceUseCase(mockRepository);
  });

  group('DeleteCompletedServiceUseCase', () {
    test('should delegate to repository on success', () async {
      when(
        mockRepository.deleteCompletedService(any),
      ).thenAnswer((_) async => const Right('Servicio eliminado exitosamente'));

      final result = await useCase.call('service-123');

      expect(result.isRight, true);
      expect(result.right, 'Servicio eliminado exitosamente');
      verify(mockRepository.deleteCompletedService('service-123')).called(1);
    });

    test('should delegate to repository on failure', () async {
      when(mockRepository.deleteCompletedService(any)).thenAnswer(
        (_) async =>
            Left(ErrorModel(errorCode: 'ERR', message: 'No se pudo eliminar')),
      );

      final result = await useCase.call('service-123');

      expect(result.isLeft, true);
      expect(result.left.message, 'No se pudo eliminar');
    });
  });
}
