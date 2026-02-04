import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/motorcycle_profile_image/data/datasources/profile_image_datasource.dart';
import 'package:motogo_frontend/src/features/motorcycle_profile_image/data/models/profile_image_model.dart';
import 'package:motogo_frontend/src/features/motorcycle_profile_image/data/repositories/profile_image_repository_impl.dart';

import 'profile_image_repository_impl_test.mocks.dart';

@GenerateMocks([ProfileImageDataSource])
void main() {
  late ProfileImageRepositoryImpl repository;
  late MockProfileImageDataSource mockDataSource;

  setUpAll(() {
    provideDummy<Either<ErrorModel, ProfileImageResponse>>(
      Right(
        ProfileImageResponse(
          model: const ProfileImageModel(motorcycleId: ''),
          message: '',
        ),
      ),
    );
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockDataSource = MockProfileImageDataSource();
    repository = ProfileImageRepositoryImpl(mockDataSource);
  });

  group('ProfileImageRepositoryImpl', () {
    const tMotorcycleId = 'moto-123';
    const tImageUrl = 'https://firebase.storage.com/image.jpg';
    const tModel = ProfileImageModel(
      motorcycleId: tMotorcycleId,
      profileImageUrl: tImageUrl,
    );
    final tResponse = ProfileImageResponse(
      model: tModel,
      message: 'Operación exitosa',
    );

    group('updateProfileImage', () {
      test(
        'should return ProfileImageEntity when datasource succeeds',
        () async {
          // Arrange
          when(
            mockDataSource.updateProfileImage(tMotorcycleId, tImageUrl),
          ).thenAnswer((_) async => Right(tResponse));

          // Act
          final result = await repository.updateProfileImage(
            tMotorcycleId,
            tImageUrl,
          );

          // Assert
          expect(result.isRight, isTrue);
          expect(result.right.motorcycleId, tMotorcycleId);
          expect(result.right.profileImageUrl, tImageUrl);
          verify(
            mockDataSource.updateProfileImage(tMotorcycleId, tImageUrl),
          ).called(1);
        },
      );

      test('should return ErrorModel when datasource fails', () async {
        // Arrange
        final error = ErrorModel(message: 'Error al actualizar imagen');
        when(
          mockDataSource.updateProfileImage(tMotorcycleId, tImageUrl),
        ).thenAnswer((_) async => Left(error));

        // Act
        final result = await repository.updateProfileImage(
          tMotorcycleId,
          tImageUrl,
        );

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left.message, 'Error al actualizar imagen');
        verify(
          mockDataSource.updateProfileImage(tMotorcycleId, tImageUrl),
        ).called(1);
      });
    });

    group('getProfileImage', () {
      test(
        'should return ProfileImageEntity when datasource succeeds',
        () async {
          // Arrange
          when(
            mockDataSource.getProfileImage(tMotorcycleId),
          ).thenAnswer((_) async => Right(tResponse));

          // Act
          final result = await repository.getProfileImage(tMotorcycleId);

          // Assert
          expect(result.isRight, isTrue);
          expect(result.right.motorcycleId, tMotorcycleId);
          expect(result.right.profileImageUrl, tImageUrl);
          verify(mockDataSource.getProfileImage(tMotorcycleId)).called(1);
        },
      );

      test(
        'should return ProfileImageEntity with null url when no image',
        () async {
          // Arrange
          const modelWithoutImage = ProfileImageModel(
            motorcycleId: tMotorcycleId,
          );
          final responseWithoutImage = ProfileImageResponse(
            model: modelWithoutImage,
            message: 'No hay imagen',
          );
          when(
            mockDataSource.getProfileImage(tMotorcycleId),
          ).thenAnswer((_) async => Right(responseWithoutImage));

          // Act
          final result = await repository.getProfileImage(tMotorcycleId);

          // Assert
          expect(result.isRight, isTrue);
          expect(result.right.motorcycleId, tMotorcycleId);
          expect(result.right.profileImageUrl, isNull);
        },
      );

      test('should return ErrorModel when datasource fails', () async {
        // Arrange
        final error = ErrorModel(message: 'Motocicleta no encontrada');
        when(
          mockDataSource.getProfileImage(tMotorcycleId),
        ).thenAnswer((_) async => Left(error));

        // Act
        final result = await repository.getProfileImage(tMotorcycleId);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left.message, 'Motocicleta no encontrada');
        verify(mockDataSource.getProfileImage(tMotorcycleId)).called(1);
      });
    });

    group('deleteProfileImage', () {
      test('should return success message when datasource succeeds', () async {
        // Arrange
        const successMessage = 'Imagen eliminada correctamente';
        when(
          mockDataSource.deleteProfileImage(tMotorcycleId),
        ).thenAnswer((_) async => const Right(successMessage));

        // Act
        final result = await repository.deleteProfileImage(tMotorcycleId);

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, successMessage);
        verify(mockDataSource.deleteProfileImage(tMotorcycleId)).called(1);
      });

      test('should return ErrorModel when datasource fails', () async {
        // Arrange
        final error = ErrorModel(message: 'No hay imagen para eliminar');
        when(
          mockDataSource.deleteProfileImage(tMotorcycleId),
        ).thenAnswer((_) async => Left(error));

        // Act
        final result = await repository.deleteProfileImage(tMotorcycleId);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left.message, 'No hay imagen para eliminar');
        verify(mockDataSource.deleteProfileImage(tMotorcycleId)).called(1);
      });

      test('should call datasource with correct motorcycleId', () async {
        // Arrange
        const customId = 'custom-moto-id';
        when(
          mockDataSource.deleteProfileImage(customId),
        ).thenAnswer((_) async => const Right('Deleted'));

        // Act
        await repository.deleteProfileImage(customId);

        // Assert
        verify(mockDataSource.deleteProfileImage(customId)).called(1);
        verifyNoMoreInteractions(mockDataSource);
      });
    });
  });
}
