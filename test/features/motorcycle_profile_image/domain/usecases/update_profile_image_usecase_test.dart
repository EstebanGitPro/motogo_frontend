import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/motorcycle_profile_image/domain/entities/profile_image_entity.dart';
import 'package:motogo_frontend/src/features/motorcycle_profile_image/domain/repositories/profile_image_repository.dart';
import 'package:motogo_frontend/src/features/motorcycle_profile_image/domain/usecases/update_profile_image_usecase.dart';

import 'update_profile_image_usecase_test.mocks.dart';

@GenerateMocks([ProfileImageRepository])
void main() {
  late UpdateProfileImageUseCase useCase;
  late MockProfileImageRepository mockRepository;

  setUpAll(() {
    provideDummy<Either<ErrorModel, ProfileImageEntity>>(
      const Right(ProfileImageEntity(motorcycleId: '')),
    );
  });

  setUp(() {
    mockRepository = MockProfileImageRepository();
    useCase = UpdateProfileImageUseCase(mockRepository);
  });

  group('UpdateProfileImageUseCase', () {
    const tMotorcycleId = 'moto-123';
    const tImageUrl = 'https://firebase.storage.com/new-image.jpg';
    const tProfileImageEntity = ProfileImageEntity(
      motorcycleId: tMotorcycleId,
      profileImageUrl: tImageUrl,
    );

    test('should return ProfileImageEntity when repository succeeds', () async {
      // Arrange
      when(
        mockRepository.updateProfileImage(tMotorcycleId, tImageUrl),
      ).thenAnswer((_) async => const Right(tProfileImageEntity));

      // Act
      final result = await useCase(
        motorcycleId: tMotorcycleId,
        imageUrl: tImageUrl,
      );

      // Assert
      expect(result.isRight, isTrue);
      expect(result.right, tProfileImageEntity);
      expect(result.right.motorcycleId, tMotorcycleId);
      expect(result.right.profileImageUrl, tImageUrl);
      verify(
        mockRepository.updateProfileImage(tMotorcycleId, tImageUrl),
      ).called(1);
    });

    test('should return ErrorModel when repository fails', () async {
      // Arrange
      final error = ErrorModel(
        message: 'No se pudo actualizar la imagen de perfil',
      );
      when(
        mockRepository.updateProfileImage(tMotorcycleId, tImageUrl),
      ).thenAnswer((_) async => Left(error));

      // Act
      final result = await useCase(
        motorcycleId: tMotorcycleId,
        imageUrl: tImageUrl,
      );

      // Assert
      expect(result.isLeft, isTrue);
      expect(result.left.message, 'No se pudo actualizar la imagen de perfil');
      verify(
        mockRepository.updateProfileImage(tMotorcycleId, tImageUrl),
      ).called(1);
    });

    test('should pass correct parameters to repository', () async {
      // Arrange
      const customMotorcycleId = 'custom-moto-id';
      const customImageUrl = 'https://custom-url.com/image.png';
      when(
        mockRepository.updateProfileImage(customMotorcycleId, customImageUrl),
      ).thenAnswer(
        (_) async => const Right(
          ProfileImageEntity(
            motorcycleId: customMotorcycleId,
            profileImageUrl: customImageUrl,
          ),
        ),
      );

      // Act
      await useCase(motorcycleId: customMotorcycleId, imageUrl: customImageUrl);

      // Assert
      verify(
        mockRepository.updateProfileImage(customMotorcycleId, customImageUrl),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
