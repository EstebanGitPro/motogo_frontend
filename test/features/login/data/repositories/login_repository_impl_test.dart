import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/user/domain/entities/user_entity.dart';
import 'package:motogo_frontend/src/features/login/data/datasources/login_data_source.dart';
import 'package:motogo_frontend/src/features/login/data/repositories/login_repository_impl.dart';
import 'package:motogo_frontend/src/features/login/domain/entities/login_result.dart';

import 'login_repository_impl_test.mocks.dart';

@GenerateMocks([LoginDataSource])
void main() {
  late LoginRepositoryImpl repository;
  late MockLoginDataSource mockDataSource;

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
    mockDataSource = MockLoginDataSource();
    repository = LoginRepositoryImpl(mockDataSource);
  });

  group('LoginRepositoryImpl', () {
    const testEmail = 'john@example.com';
    const testPassword = 'password123';

    group('login', () {
      test('should return LoginResult when datasource succeeds', () async {
        // Arrange
        when(
          mockDataSource.loginPerson(testEmail, testPassword),
        ).thenAnswer((_) async => const Right(testLoginResult));

        // Act
        final result = await repository.login(testEmail, testPassword);

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, testLoginResult);
        verify(mockDataSource.loginPerson(testEmail, testPassword)).called(1);
      });

      test('should return ErrorModel when datasource fails', () async {
        // Arrange
        final errorModel = ErrorModel(
          errorCode: 'INVALID_CREDENTIALS',
          message: 'Credenciales inválidas',
        );
        when(
          mockDataSource.loginPerson(testEmail, testPassword),
        ).thenAnswer((_) async => Left(errorModel));

        // Act
        final result = await repository.login(testEmail, testPassword);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, errorModel);
        verify(mockDataSource.loginPerson(testEmail, testPassword)).called(1);
      });

      test('should pass email and password to datasource', () async {
        // Arrange
        const differentEmail = 'another@example.com';
        const differentPassword = 'different123';
        when(
          mockDataSource.loginPerson(differentEmail, differentPassword),
        ).thenAnswer((_) async => const Right(testLoginResult));

        // Act
        await repository.login(differentEmail, differentPassword);

        // Assert
        verify(
          mockDataSource.loginPerson(differentEmail, differentPassword),
        ).called(1);
        verifyNever(mockDataSource.loginPerson(testEmail, testPassword));
      });
    });
  });
}
