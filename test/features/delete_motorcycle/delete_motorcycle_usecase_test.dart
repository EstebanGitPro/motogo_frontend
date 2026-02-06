import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/delete_motorcycle/domain/repositories/delete_motorcycle_repository.dart';
import 'package:motogo_frontend/src/features/delete_motorcycle/domain/usecases/delete_motorcycle_usecase.dart';

import 'delete_motorcycle_usecase_test.mocks.dart';

@GenerateMocks([DeleteMotorcycleRepository])
void main() {
  late DeleteMotorcycleUseCase useCase;
  late MockDeleteMotorcycleRepository mockRepository;

  setUpAll(() {
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockRepository = MockDeleteMotorcycleRepository();
    useCase = DeleteMotorcycleUseCase(mockRepository);
  });

  group('DeleteMotorcycleUseCase', () {
    const testMotorcycleId = 'test-motorcycle-123';

    group('call', () {
      test('should return success message when repository succeeds', () async {
        // Arrange
        const successMessage = 'Motocicleta eliminada exitosamente';
        when(
          mockRepository.deleteMotorcycle(testMotorcycleId),
        ).thenAnswer((_) async => const Right(successMessage));

        // Act
        final result = await useCase.call(testMotorcycleId);

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, successMessage);
        verify(mockRepository.deleteMotorcycle(testMotorcycleId)).called(1);
      });

      test('should return ErrorModel when repository fails', () async {
        // Arrange
        final errorModel = ErrorModel(
          errorCode: 'ERR_MOTORCYCLE_001',
          message: 'No se puede eliminar la motocicleta',
        );
        when(
          mockRepository.deleteMotorcycle(testMotorcycleId),
        ).thenAnswer((_) async => Left(errorModel));

        // Act
        final result = await useCase.call(testMotorcycleId);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, errorModel);
        verify(mockRepository.deleteMotorcycle(testMotorcycleId)).called(1);
      });

      test('should delegate to repository with correct ID', () async {
        // Arrange
        const differentId = 'another-motorcycle-uuid';
        when(
          mockRepository.deleteMotorcycle(differentId),
        ).thenAnswer((_) async => const Right('Deleted'));

        // Act
        await useCase.call(differentId);

        // Assert
        verify(mockRepository.deleteMotorcycle(differentId)).called(1);
        verifyNever(mockRepository.deleteMotorcycle(testMotorcycleId));
      });

      test('should be callable with call syntax', () async {
        // Arrange
        when(
          mockRepository.deleteMotorcycle(testMotorcycleId),
        ).thenAnswer((_) async => const Right('Success'));

        // Act - using call() syntax
        final result = await useCase(testMotorcycleId);

        // Assert
        expect(result.isRight, isTrue);
      });
    });
  });
}
