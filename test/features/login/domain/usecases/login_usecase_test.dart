import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/user/domain/entities/user_entity.dart';
import 'package:motogo_frontend/src/features/login/domain/entities/login_result.dart';
import 'package:motogo_frontend/src/features/login/domain/repositories/login_repository.dart';
import 'package:motogo_frontend/src/features/login/domain/usecases/login_usecase.dart';

import 'login_usecase_test.mocks.dart';

@GenerateMocks([LoginRepository])
void main() {
  late LoginUseCase useCase;
  late MockLoginRepository mockRepository;

  const testUser = UserEntity(
    id: 'test-user-id',
    identityNumber: '123456789',
    firstName: 'John',
    lastName: 'Doe',
    email: 'john@example.com',
    phoneNumber: '1234567890',
    role: 'USER',
  );

  const testLoginResult = LoginResult(
    user: testUser,
    message: 'Login exitoso',
    code: 'AUTH_SUCCESS',
  );

  setUpAll(() {
    provideDummy<Either<ErrorModel, LoginResult>>(const Right(testLoginResult));
  });

  setUp(() {
    mockRepository = MockLoginRepository();
    useCase = LoginUseCase(mockRepository);
  });

  group('LoginUseCase', () {
    const testEmail = 'john@example.com';
    const testPassword = 'password123';

    group('call', () {
      test('should return LoginResult when login succeeds', () async {
        // Arrange
        when(
          mockRepository.login(testEmail, testPassword),
        ).thenAnswer((_) async => const Right(testLoginResult));

        // Act
        final result = await useCase.call(
          email: testEmail,
          password: testPassword,
        );

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, testLoginResult);
        expect(result.right.user, testUser);
        expect(result.right.message, 'Login exitoso');
        verify(mockRepository.login(testEmail, testPassword)).called(1);
      });

      test('should return ErrorModel when login fails', () async {
        // Arrange
        final errorModel = ErrorModel(
          errorCode: 'INVALID_CREDENTIALS',
          message: 'Credenciales inválidas',
        );
        when(
          mockRepository.login(testEmail, testPassword),
        ).thenAnswer((_) async => Left(errorModel));

        // Act
        final result = await useCase.call(
          email: testEmail,
          password: testPassword,
        );

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, errorModel);
        verify(mockRepository.login(testEmail, testPassword)).called(1);
      });

      test('should pass email and password to repository', () async {
        // Arrange
        const differentEmail = 'another@example.com';
        const differentPassword = 'different123';
        when(
          mockRepository.login(differentEmail, differentPassword),
        ).thenAnswer((_) async => const Right(testLoginResult));

        // Act
        await useCase.call(email: differentEmail, password: differentPassword);

        // Assert
        verify(
          mockRepository.login(differentEmail, differentPassword),
        ).called(1);
        verifyNever(mockRepository.login(testEmail, testPassword));
      });

      test('should be callable with call syntax', () async {
        // Arrange
        when(
          mockRepository.login(testEmail, testPassword),
        ).thenAnswer((_) async => const Right(testLoginResult));

        // Act - using call() syntax
        final result = await useCase(email: testEmail, password: testPassword);

        // Assert
        expect(result.isRight, isTrue);
      });
    });
  });
}
