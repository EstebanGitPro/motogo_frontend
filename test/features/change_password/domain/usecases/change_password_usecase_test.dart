import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/change_password/domain/repositories/change_password_repository.dart';
import 'package:motogo_frontend/src/features/change_password/domain/usecases/change_password_usecase.dart';

import 'change_password_usecase_test.mocks.dart';

@GenerateMocks([ChangePasswordRepository])
void main() {
  late ChangePasswordUseCase useCase;
  late MockChangePasswordRepository mockRepository;

  setUpAll(() {
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockRepository = MockChangePasswordRepository();
    useCase = ChangePasswordUseCase(mockRepository);
  });

  group('ChangePasswordUseCase', () {
    const currentPassword = 'oldPassword123';
    const newPassword = 'newPassword456';

    group('call', () {
      test(
        'should return success message when password change succeeds',
        () async {
          // Arrange
          const successMessage = 'Contraseña actualizada exitosamente';
          when(
            mockRepository.changePassword(
              currentPassword: currentPassword,
              newPassword: newPassword,
            ),
          ).thenAnswer((_) async => const Right(successMessage));

          // Act
          final result = await useCase.call(
            currentPassword: currentPassword,
            newPassword: newPassword,
          );

          // Assert
          expect(result.isRight, isTrue);
          expect(result.right, successMessage);
          verify(
            mockRepository.changePassword(
              currentPassword: currentPassword,
              newPassword: newPassword,
            ),
          ).called(1);
        },
      );

      test('should return ErrorModel when password change fails', () async {
        // Arrange
        final errorModel = ErrorModel(
          errorCode: 'INVALID_PASSWORD',
          message: 'La contraseña actual es incorrecta',
        );
        when(
          mockRepository.changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          ),
        ).thenAnswer((_) async => Left(errorModel));

        // Act
        final result = await useCase.call(
          currentPassword: currentPassword,
          newPassword: newPassword,
        );

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, errorModel);
        verify(
          mockRepository.changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          ),
        ).called(1);
      });

      test('should pass both passwords to repository', () async {
        // Arrange
        const differentCurrent = 'differentOld';
        const differentNew = 'differentNew';
        when(
          mockRepository.changePassword(
            currentPassword: differentCurrent,
            newPassword: differentNew,
          ),
        ).thenAnswer((_) async => const Right('Changed'));

        // Act
        await useCase.call(
          currentPassword: differentCurrent,
          newPassword: differentNew,
        );

        // Assert
        verify(
          mockRepository.changePassword(
            currentPassword: differentCurrent,
            newPassword: differentNew,
          ),
        ).called(1);
      });

      test('should be callable with call syntax', () async {
        // Arrange
        when(
          mockRepository.changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          ),
        ).thenAnswer((_) async => const Right('Success'));

        // Act - using call() syntax
        final result = await useCase(
          currentPassword: currentPassword,
          newPassword: newPassword,
        );

        // Assert
        expect(result.isRight, isTrue);
      });
    });
  });
}
