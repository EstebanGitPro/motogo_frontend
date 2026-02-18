import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/admin_services/domain/entities/admin_service_entity.dart';
import 'package:motogo_frontend/src/features/admin_services/domain/repositories/admin_service_repository.dart';
import 'package:motogo_frontend/src/features/admin_services/domain/usecases/admin_service_usecases.dart';

import 'admin_service_usecases_test.mocks.dart';

@GenerateMocks([AdminServiceRepository])
void main() {
  late MockAdminServiceRepository mockRepository;

  final testEntity = AdminServiceEntity(
    id: 'svc-1',
    name: 'Cambio de aceite',
    serviceType: 'MAINTENANCE',
  );
  final errorModel = ErrorModel(
    message: 'Error de prueba',
    errorCode: 'ERR_001',
  );

  setUp(() {
    mockRepository = MockAdminServiceRepository();
  });

  setUpAll(() {
    provideDummy<Either<ErrorModel, List<AdminServiceEntity>>>(const Right([]));
    provideDummy<Either<ErrorModel, AdminServiceEntity>>(
      Right(AdminServiceEntity(id: '', name: '', serviceType: '')),
    );
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  group('GetServicesCatalogUseCase', () {
    late GetServicesCatalogUseCase useCase;

    setUp(() {
      useCase = GetServicesCatalogUseCase(mockRepository);
    });

    test('should return list of services on success', () async {
      when(
        mockRepository.getServices(),
      ).thenAnswer((_) async => Right([testEntity]));

      final result = await useCase.call();

      expect(result.isRight, isTrue);
      expect(result.right, [testEntity]);
      verify(mockRepository.getServices()).called(1);
    });

    test('should return ErrorModel on failure', () async {
      when(
        mockRepository.getServices(),
      ).thenAnswer((_) async => Left(errorModel));

      final result = await useCase.call();

      expect(result.isLeft, isTrue);
      expect(result.left, errorModel);
    });
  });

  group('UpdateServiceUseCase', () {
    late UpdateServiceUseCase useCase;

    setUp(() {
      useCase = UpdateServiceUseCase(mockRepository);
    });

    test('should return updated service on success', () async {
      when(
        mockRepository.updateService(
          serviceId: 'svc-1',
          name: 'Cambio aceite premium',
          serviceType: 'MAINTENANCE',
          description: 'Desc',
          isActive: true,
        ),
      ).thenAnswer((_) async => Right(testEntity));

      final result = await useCase.call(
        serviceId: 'svc-1',
        name: 'Cambio aceite premium',
        serviceType: 'MAINTENANCE',
        description: 'Desc',
        isActive: true,
      );

      expect(result.isRight, isTrue);
      expect(result.right, testEntity);
    });

    test('should return ErrorModel on failure', () async {
      when(
        mockRepository.updateService(
          serviceId: 'svc-1',
          name: 'Test',
          serviceType: 'REPAIR',
        ),
      ).thenAnswer((_) async => Left(errorModel));

      final result = await useCase.call(
        serviceId: 'svc-1',
        name: 'Test',
        serviceType: 'REPAIR',
      );

      expect(result.isLeft, isTrue);
      expect(result.left, errorModel);
    });
  });

  group('ActivateServiceUseCase', () {
    late ActivateServiceUseCase useCase;

    setUp(() {
      useCase = ActivateServiceUseCase(mockRepository);
    });

    test('should return success message on success', () async {
      when(
        mockRepository.activateService('svc-1'),
      ).thenAnswer((_) async => const Right('Servicio activado'));

      final result = await useCase.call('svc-1');

      expect(result.isRight, isTrue);
      expect(result.right, 'Servicio activado');
      verify(mockRepository.activateService('svc-1')).called(1);
    });

    test('should return ErrorModel on failure', () async {
      when(
        mockRepository.activateService('svc-1'),
      ).thenAnswer((_) async => Left(errorModel));

      final result = await useCase.call('svc-1');

      expect(result.isLeft, isTrue);
    });
  });

  group('DeactivateServiceUseCase', () {
    late DeactivateServiceUseCase useCase;

    setUp(() {
      useCase = DeactivateServiceUseCase(mockRepository);
    });

    test('should return success message on success', () async {
      when(
        mockRepository.deactivateService('svc-1'),
      ).thenAnswer((_) async => const Right('Servicio desactivado'));

      final result = await useCase.call('svc-1');

      expect(result.isRight, isTrue);
      expect(result.right, 'Servicio desactivado');
      verify(mockRepository.deactivateService('svc-1')).called(1);
    });

    test('should return ErrorModel on failure', () async {
      when(
        mockRepository.deactivateService('svc-1'),
      ).thenAnswer((_) async => Left(errorModel));

      final result = await useCase.call('svc-1');

      expect(result.isLeft, isTrue);
    });
  });
}
