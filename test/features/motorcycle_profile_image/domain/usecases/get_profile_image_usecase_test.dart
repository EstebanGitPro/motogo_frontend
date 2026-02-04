import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/motorcycle_profile_image/domain/entities/profile_image_entity.dart';
import 'package:motogo_frontend/src/features/motorcycle_profile_image/domain/repositories/profile_image_repository.dart';
import 'package:motogo_frontend/src/features/motorcycle_profile_image/domain/usecases/get_profile_image_usecase.dart';

import 'get_profile_image_usecase_test.mocks.dart';

@GenerateMocks([ProfileImageRepository])
void main() {
  late GetProfileImageUseCase useCase;
  late MockProfileImageRepository mockRepository;

  setUpAll(() {
    provideDummy<Either<ErrorModel, ProfileImageEntity>>(
      const Right(ProfileImageEntity(motorcycleId: '')),
    );
  });

  setUp(() {
    mockRepository = MockProfileImageRepository();
    useCase = GetProfileImageUseCase(mockRepository);
  });

  group('GetProfileImageUseCase', () {
    const tMotorcycleId = 'moto-123';
    const tProfileImageEntity = ProfileImageEntity(
      motorcycleId: tMotorcycleId,
      profileImageUrl: 'https://firebase.storage.com/profile-image.jpg',
    );

    test('should return ProfileImageEntity when repository succeeds', () async {
      // Arrange
      when(
        mockRepository.getProfileImage(tMotorcycleId),
      ).thenAnswer((_) async => const Right(tProfileImageEntity));

      // Act
      final result = await useCase(motorcycleId: tMotorcycleId);

      // Assert
      expect(result.isRight, isTrue);
      expect(result.right, tProfileImageEntity);
      expect(result.right.motorcycleId, tMotorcycleId);
      expect(result.right.profileImageUrl, isNotNull);
      verify(mockRepository.getProfileImage(tMotorcycleId)).called(1);
    });

    test(
      'should return ProfileImageEntity with null url when no image exists',
      () async {
        // Arrange
        const entityWithoutImage = ProfileImageEntity(
          motorcycleId: tMotorcycleId,
        );
        when(
          mockRepository.getProfileImage(tMotorcycleId),
        ).thenAnswer((_) async => const Right(entityWithoutImage));

        // Act
        final result = await useCase(motorcycleId: tMotorcycleId);

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right.motorcycleId, tMotorcycleId);
        expect(result.right.profileImageUrl, isNull);
        verify(mockRepository.getProfileImage(tMotorcycleId)).called(1);
      },
    );

    test('should return ErrorModel when repository fails', () async {
      // Arrange
      final error = ErrorModel(message: 'Motocicleta no encontrada');
      when(
        mockRepository.getProfileImage(tMotorcycleId),
      ).thenAnswer((_) async => Left(error));

      // Act
      final result = await useCase(motorcycleId: tMotorcycleId);

      // Assert
      expect(result.isLeft, isTrue);
      expect(result.left.message, 'Motocicleta no encontrada');
      verify(mockRepository.getProfileImage(tMotorcycleId)).called(1);
    });

    test('should pass correct motorcycleId to repository', () async {
      // Arrange
      const customMotorcycleId = 'custom-moto-xyz';
      when(mockRepository.getProfileImage(customMotorcycleId)).thenAnswer(
        (_) async =>
            const Right(ProfileImageEntity(motorcycleId: customMotorcycleId)),
      );

      // Act
      await useCase(motorcycleId: customMotorcycleId);

      // Assert
      verify(mockRepository.getProfileImage(customMotorcycleId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
