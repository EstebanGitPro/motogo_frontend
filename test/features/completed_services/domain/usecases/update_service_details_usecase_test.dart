import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/repositories/completed_services_repository.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/usecases/update_service_details_usecase.dart';

import 'update_service_details_usecase_test.mocks.dart';

@GenerateMocks([CompletedServicesRepository])
void main() {
  late UpdateServiceDetailsUseCase useCase;
  late MockCompletedServicesRepository mockRepository;

  setUpAll(() {
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockRepository = MockCompletedServicesRepository();
    useCase = UpdateServiceDetailsUseCase(mockRepository);
  });

  test('should forward call to repository.updateServiceDetails', () async {
    when(
      mockRepository.updateServiceDetails(
        any,
        quotedPrice: anyNamed('quotedPrice'),
        finalPrice: anyNamed('finalPrice'),
        representativeNotes: anyNamed('representativeNotes'),
      ),
    ).thenAnswer(
      (_) async => const Right('Detalles actualizados exitosamente'),
    );

    final result = await useCase(
      'svc-123',
      quotedPrice: 200000,
      finalPrice: 180000,
      representativeNotes: 'Revisión completa',
    );

    expect(result.isRight, true);
    expect(result.right, 'Detalles actualizados exitosamente');
    verify(
      mockRepository.updateServiceDetails(
        'svc-123',
        quotedPrice: 200000,
        finalPrice: 180000,
        representativeNotes: 'Revisión completa',
      ),
    ).called(1);
  });

  test('should return ErrorModel on failure', () async {
    when(
      mockRepository.updateServiceDetails(
        any,
        quotedPrice: anyNamed('quotedPrice'),
        finalPrice: anyNamed('finalPrice'),
        representativeNotes: anyNamed('representativeNotes'),
      ),
    ).thenAnswer(
      (_) async =>
          Left(ErrorModel(errorCode: 'ERR', message: 'No se puede editar')),
    );

    final result = await useCase('svc-123', quotedPrice: 100000);

    expect(result.isLeft, true);
    expect(result.left.message, 'No se puede editar');
  });

  test('should forward with only partial fields', () async {
    when(
      mockRepository.updateServiceDetails(
        any,
        quotedPrice: anyNamed('quotedPrice'),
        finalPrice: anyNamed('finalPrice'),
        representativeNotes: anyNamed('representativeNotes'),
      ),
    ).thenAnswer(
      (_) async => const Right('Detalles actualizados exitosamente'),
    );

    final result = await useCase('svc-456', representativeNotes: 'Solo notas');

    expect(result.isRight, true);
    verify(
      mockRepository.updateServiceDetails(
        'svc-456',
        representativeNotes: 'Solo notas',
      ),
    ).called(1);
  });
}
