import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/user/domain/entities/user_entity.dart';
import 'package:motogo_frontend/src/features/login/domain/entities/login_result.dart';

void main() {
  group('LoginResult', () {
    late UserEntity testUser;

    setUp(() {
      testUser = const UserEntity(
        id: 'test-user-id',
        identityNumber: '123456789',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@example.com',
        phoneNumber: '1234567890',
        role: 'USER',
      );
    });

    group('constructor', () {
      test('should create instance with required fields', () {
        // Act
        final result = LoginResult(
          user: testUser,
          message: 'Login exitoso',
          code: 'AUTH_SUCCESS',
        );

        // Assert
        expect(result.user, testUser);
        expect(result.message, 'Login exitoso');
        expect(result.code, 'AUTH_SUCCESS');
      });

      test('should support const constructor', () {
        // Act & Assert
        const result = LoginResult(
          user: UserEntity(
            id: 'id',
            identityNumber: '111111111',
            firstName: 'Test',
            lastName: 'User',
            email: 'test@example.com',
            phoneNumber: '0000000000',
            role: 'USER',
          ),
          message: 'Success',
          code: 'OK',
        );

        expect(result, isA<LoginResult>());
      });

      test('should preserve user entity properties', () {
        // Act
        final result = LoginResult(
          user: testUser,
          message: 'Login exitoso',
          code: 'AUTH_SUCCESS',
        );

        // Assert
        expect(result.user.id, 'test-user-id');
        expect(result.user.firstName, 'John');
        expect(result.user.lastName, 'Doe');
        expect(result.user.email, 'john@example.com');
        expect(result.user.role, 'USER');
      });

      test('should allow empty code', () {
        // Act
        final result = LoginResult(
          user: testUser,
          message: 'Login exitoso',
          code: '',
        );

        // Assert
        expect(result.code, isEmpty);
      });

      test('should allow backend message variations', () {
        // Act
        final result1 = LoginResult(
          user: testUser,
          message: 'Bienvenido de nuevo',
          code: 'MOD_AUTH_001',
        );

        final result2 = LoginResult(
          user: testUser,
          message: 'Inicio de sesión exitoso',
          code: 'MOD_AUTH_002',
        );

        // Assert
        expect(result1.message, 'Bienvenido de nuevo');
        expect(result2.message, 'Inicio de sesión exitoso');
      });
    });
  });
}
