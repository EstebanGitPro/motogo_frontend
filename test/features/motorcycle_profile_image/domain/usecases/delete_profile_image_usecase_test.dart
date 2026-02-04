import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/motorcycle_profile_image/domain/repositories/profile_image_repository.dart';
import 'package:motogo_frontend/src/features/motorcycle_profile_image/domain/usecases/delete_profile_image_usecase.dart';

import 'delete_profile_image_usecase_test.mocks.dart';

@GenerateMocks([ProfileImageRepository])
void main() {
  late DeleteProfileImageUseCase useCase;
  late MockProfileImageRepository mockRepository;

  setUpAll(() {
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockRepository = MockProfileImageRepository();
    useCase = DeleteProfileImageUseCase(mockRepository);
  });

  group('DeleteProfileImageUseCase', () {
    const tMotorcycleId = 'moto-123';
    const tSuccessMessage = 'La imagen de perfil fue eliminada correctamente';

    test('should return success message when repository succeeds', () async {
      // Arrange
      when(
        mockRepository.deleteProfileImage(tMotorcycleId),
      ).thenAnswer((_) async => const Right(tSuccessMessage));

      // Act
      final result = await useCase(motorcycleId: tMotorcycleId);

      // Assert
      expect(result.isRight, isTrue);
      expect(result.right, tSuccessMessage);
      verify(mockRepository.deleteProfileImage(tMotorcycleId)).called(1);
    });

    test('should return ErrorModel when repository fails', () async {
      // Arrange
      final error = ErrorModel(
        message: 'No hay imagen de perfil para eliminar',
      );
      when(
        mockRepository.deleteProfileImage(tMotorcycleId),
      ).thenAnswer((_) async => Left(error));

      // Act
      final result = await useCase(motorcycleId: tMotorcycleId);

      // Assert
      expect(result.isLeft, isTrue);
      expect(result.left.message, 'No hay imagen de perfil para eliminar');
      verify(mockRepository.deleteProfileImage(tMotorcycleId)).called(1);
    });

    test('should return ErrorModel when motorcycle not found', () async {
      // Arrange
      final error = ErrorModel(message: 'Motocicleta no encontrada');
      when(
        mockRepository.deleteProfileImage(tMotorcycleId),
      ).thenAnswer((_) async => Left(error));

      // Act
      final result = await useCase(motorcycleId: tMotorcycleId);

      // Assert
      expect(result.isLeft, isTrue);
      expect(result.left.message, 'Motocicleta no encontrada');
      verify(mockRepository.deleteProfileImage(tMotorcycleId)).called(1);
    });

    test('should pass correct motorcycleId to repository', () async {
      // Arrange
      const customMotorcycleId = 'custom-moto-delete';
      when(
        mockRepository.deleteProfileImage(customMotorcycleId),
      ).thenAnswer((_) async => const Right('Eliminado'));

      // Act
      await useCase(motorcycleId: customMotorcycleId);

      // Assert
      verify(mockRepository.deleteProfileImage(customMotorcycleId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
