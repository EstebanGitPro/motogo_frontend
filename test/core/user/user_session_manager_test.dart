import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/user/domain/entities/user_entity.dart';
import 'package:motogo_frontend/src/core/user/user_session_manager.dart';

import 'user_session_manager_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late UserSessionManager manager;
  late MockFlutterSecureStorage mockStorage;

  const testUser = UserEntity(
    id: 'user-001',
    identityNumber: '123456789',
    firstName: 'Juan',
    lastName: 'Pérez',
    email: 'juan@test.com',
    phoneNumber: '3001234567',
    role: 'Representative',
  );

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    manager = UserSessionManager.instance;
    manager.resetForTesting();
    manager.secureStorageOverride = mockStorage;

    // Default stub: write siempre exitoso
    when(
      mockStorage.write(key: anyNamed('key'), value: anyNamed('value')),
    ).thenAnswer((_) async {});

    // Default stub: delete siempre exitoso
    when(mockStorage.delete(key: anyNamed('key'))).thenAnswer((_) async {});

    // Default stub: read retorna null por defecto
    when(mockStorage.read(key: anyNamed('key'))).thenAnswer((_) async => null);
  });

  tearDown(() {
    manager.resetForTesting();
  });

  group('UserSessionManager', () {
    group('singleton', () {
      test('should return the same instance', () {
        final instance1 = UserSessionManager.instance;
        final instance2 = UserSessionManager.instance;

        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('initial state', () {
      test('currentUser should be null', () {
        expect(manager.currentUser, isNull);
      });

      test('accessToken should be null', () {
        expect(manager.accessToken, isNull);
      });

      test('refreshToken should be null', () {
        expect(manager.refreshToken, isNull);
      });

      test('isAuthenticated should be false', () {
        expect(manager.isAuthenticated, isFalse);
      });
    });

    group('saveSession', () {
      test('should persist tokens and user in memory and storage', () async {
        await manager.saveSession(
          accessToken: 'test-access-token',
          refreshToken: 'test-refresh-token',
          user: testUser,
        );

        // Verificar cache en memoria
        expect(manager.accessToken, equals('test-access-token'));
        expect(manager.refreshToken, equals('test-refresh-token'));
        expect(manager.currentUser, equals(testUser));
        expect(manager.isAuthenticated, isTrue);

        // Verificar escrituras en storage
        verify(
          mockStorage.write(key: 'access_token', value: 'test-access-token'),
        ).called(1);
        verify(
          mockStorage.write(key: 'refresh_token', value: 'test-refresh-token'),
        ).called(1);
        verify(
          mockStorage.write(key: 'user_data', value: anyNamed('value')),
        ).called(1);
        verify(mockStorage.write(key: 'user_id', value: 'user-001')).called(1);
      });

      test('should accept null refreshToken', () async {
        await manager.saveSession(
          accessToken: 'test-access-token',
          user: testUser,
        );

        expect(manager.accessToken, equals('test-access-token'));
        expect(manager.refreshToken, isNull);
        expect(manager.currentUser, equals(testUser));

        verifyNever(
          mockStorage.write(key: 'refresh_token', value: anyNamed('value')),
        );
      });
    });

    group('loadSession', () {
      test('should load tokens from storage into memory', () async {
        when(
          mockStorage.read(key: 'access_token'),
        ).thenAnswer((_) async => 'stored-access-token');
        when(
          mockStorage.read(key: 'refresh_token'),
        ).thenAnswer((_) async => 'stored-refresh-token');
        when(mockStorage.read(key: 'user_data')).thenAnswer((_) async => null);

        await manager.loadSession();

        expect(manager.accessToken, equals('stored-access-token'));
        expect(manager.refreshToken, equals('stored-refresh-token'));
      });

      test('should handle null values from storage', () async {
        await manager.loadSession();

        expect(manager.accessToken, isNull);
        expect(manager.refreshToken, isNull);
        expect(manager.currentUser, isNull);
        expect(manager.isAuthenticated, isFalse);
      });
    });

    group('clearSession', () {
      test('should clear memory and storage', () async {
        // Primero guardar sesión
        await manager.saveSession(
          accessToken: 'test-token',
          refreshToken: 'test-refresh',
          user: testUser,
        );

        // Limpiar
        await manager.clearSession();

        // Verificar memoria limpia
        expect(manager.currentUser, isNull);
        expect(manager.accessToken, isNull);
        expect(manager.refreshToken, isNull);
        expect(manager.isAuthenticated, isFalse);

        // Verificar deletes en storage
        verify(mockStorage.delete(key: 'access_token')).called(1);
        verify(mockStorage.delete(key: 'refresh_token')).called(1);
        verify(mockStorage.delete(key: 'user_data')).called(1);
        verify(mockStorage.delete(key: 'user_id')).called(1);
      });
    });

    group('getAccessToken', () {
      test('should return token from memory if available', () async {
        await manager.saveSession(
          accessToken: 'in-memory-token',
          user: testUser,
        );

        final token = await manager.getAccessToken();

        expect(token, equals('in-memory-token'));
      });

      test('should fallback to storage when memory is empty', () async {
        when(
          mockStorage.read(key: 'access_token'),
        ).thenAnswer((_) async => 'storage-token');

        final token = await manager.getAccessToken();

        expect(token, equals('storage-token'));
        verify(mockStorage.read(key: 'access_token')).called(1);
      });
    });

    group('getCurrentUser', () {
      test('should return user from memory if available', () async {
        await manager.saveSession(accessToken: 'token', user: testUser);

        final user = await manager.getCurrentUser();

        expect(user, equals(testUser));
      });

      test('should return null when no session exists', () async {
        final user = await manager.getCurrentUser();

        expect(user, isNull);
      });
    });

    group('updateUser', () {
      test('should update user in memory and storage', () async {
        const updatedUser = UserEntity(
          id: 'user-001',
          identityNumber: '123456789',
          firstName: 'Juan Carlos',
          lastName: 'Pérez',
          email: 'juancarlos@test.com',
          phoneNumber: '3001234567',
          role: 'Representative',
        );

        await manager.updateUser(updatedUser);

        expect(manager.currentUser, equals(updatedUser));
        verify(
          mockStorage.write(key: 'user_data', value: anyNamed('value')),
        ).called(1);
      });
    });

    group('updateTokens', () {
      test('should update accessToken in memory and storage', () async {
        await manager.updateTokens(accessToken: 'new-access-token');

        expect(manager.accessToken, equals('new-access-token'));
        verify(
          mockStorage.write(key: 'access_token', value: 'new-access-token'),
        ).called(1);
      });

      test('should update both tokens when provided', () async {
        await manager.updateTokens(
          accessToken: 'new-access',
          refreshToken: 'new-refresh',
        );

        expect(manager.accessToken, equals('new-access'));
        expect(manager.refreshToken, equals('new-refresh'));
        verify(
          mockStorage.write(key: 'access_token', value: 'new-access'),
        ).called(1);
        verify(
          mockStorage.write(key: 'refresh_token', value: 'new-refresh'),
        ).called(1);
      });

      test('should not update refreshToken when null', () async {
        await manager.updateTokens(accessToken: 'only-access');

        verifyNever(
          mockStorage.write(key: 'refresh_token', value: anyNamed('value')),
        );
      });
    });
  });
}
