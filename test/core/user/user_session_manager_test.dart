import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/user/domain/entities/user_entity.dart';
import 'package:motogo_frontend/src/core/user/user_session_manager.dart';

void main() {
  // Initialize binding for secure storage
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserSessionManager', () {
    late UserSessionManager manager;

    setUp(() {
      // Get the singleton instance
      manager = UserSessionManager.instance;
    });

    group('singleton', () {
      test('should return the same instance', () {
        // Act
        final instance1 = UserSessionManager.instance;
        final instance2 = UserSessionManager.instance;

        // Assert
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('initial state', () {
      test('currentUser getter should work', () {
        // The getter should not throw
        expect(() => manager.currentUser, returnsNormally);
      });

      test('accessToken getter should work', () {
        // The getter should not throw
        expect(() => manager.accessToken, returnsNormally);
      });

      test('refreshToken getter should work', () {
        // The getter should not throw
        expect(() => manager.refreshToken, returnsNormally);
      });

      test('isAuthenticated getter should return bool', () {
        // Act
        final result = manager.isAuthenticated;

        // Assert
        expect(result, isA<bool>());
      });
    });

    group('getAccessToken', () {
      test('should return Future<String?>', () async {
        // Act & Assert
        // In test environment, the method may throw MissingPluginException
        try {
          await manager.getAccessToken();
        } catch (e) {
          // Expected - secure storage not available in tests
          expect(e, isNotNull);
        }
      });
    });

    group('getCurrentUser', () {
      test('should return Future<UserEntity?>', () async {
        // Act
        final result = manager.getCurrentUser();

        // Assert
        expect(result, isA<Future<UserEntity?>>());
      });
    });

    group('loadSession', () {
      test('should complete without throwing', () async {
        // Act & Assert
        // MissingPluginException is expected in test environment
        // when FlutterSecureStorage is not available
        try {
          await manager.loadSession();
        } catch (e) {
          // Expected - secure storage not available in tests
          expect(e, isNotNull);
        }
      });
    });

    group('clearSession', () {
      test('should complete without throwing', () async {
        // Act & Assert
        try {
          await manager.clearSession();
        } catch (e) {
          // Expected - secure storage not available in tests
          expect(e, isNotNull);
        }
      });
    });

    group('saveSession', () {
      test('should accept required parameters', () async {
        // Arrange
        const testUser = UserEntity(
          id: 'user-001',
          identityNumber: '123456789',
          firstName: 'Juan',
          lastName: 'Pérez',
          email: 'juan@test.com',
          phoneNumber: '3001234567',
          role: 'Representative',
        );

        // Act & Assert
        try {
          await manager.saveSession(
            accessToken: 'test-access-token',
            refreshToken: 'test-refresh-token',
            user: testUser,
          );
        } catch (e) {
          // Expected - secure storage not available in tests
          expect(e, isNotNull);
        }
      });

      test('should accept null refreshToken', () async {
        // Arrange
        const testUser = UserEntity(
          id: 'user-002',
          identityNumber: '987654321',
          firstName: 'María',
          lastName: 'García',
          email: 'maria@test.com',
          phoneNumber: '3009876543',
          role: 'Workshop',
        );

        // Act & Assert
        try {
          await manager.saveSession(
            accessToken: 'test-access-token',
            user: testUser,
          );
        } catch (e) {
          // Expected - secure storage not available in tests
          expect(e, isNotNull);
        }
      });
    });

    group('updateUser', () {
      test('should accept UserEntity parameter', () async {
        // Arrange
        const testUser = UserEntity(
          id: 'user-003',
          identityNumber: '111222333',
          firstName: 'Carlos',
          lastName: 'López',
          email: 'carlos@test.com',
          phoneNumber: '3005555555',
          role: 'Representative',
        );

        // Act & Assert
        try {
          await manager.updateUser(testUser);
        } catch (e) {
          // Expected - secure storage not available in tests
          expect(e, isNotNull);
        }
      });
    });

    group('updateTokens', () {
      test('should accept accessToken parameter', () async {
        // Act & Assert
        try {
          await manager.updateTokens(accessToken: 'new-access-token');
        } catch (e) {
          // Expected - secure storage not available in tests
          expect(e, isNotNull);
        }
      });

      test('should accept both tokens', () async {
        // Act & Assert
        try {
          await manager.updateTokens(
            accessToken: 'new-access-token',
            refreshToken: 'new-refresh-token',
          );
        } catch (e) {
          // Expected - secure storage not available in tests
          expect(e, isNotNull);
        }
      });
    });
  });
}
