import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:motogo_frontend/src/core/user/data/models/user_model.dart';
import 'package:motogo_frontend/src/core/user/domain/entities/user_entity.dart';
import 'package:motogo_frontend/src/core/utils/app_logger.dart';

/// Singleton que gestiona la sesión del usuario autenticado.
///
/// Responsabilidades:
/// - Mantiene en memoria el usuario actual y tokens
/// - Persiste y recupera datos de SecureStorage
/// - Provee acceso centralizado al estado de autenticación
class UserSessionManager {
  // Singleton instance
  static final UserSessionManager _instance = UserSessionManager._internal();
  static UserSessionManager get instance => _instance;

  UserSessionManager._internal();

  // Storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _userIdKey = 'user_id';

  // Secure storage instance (inyectable para tests)
  FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Permite inyectar un mock de FlutterSecureStorage en tests.
  @visibleForTesting
  set secureStorageOverride(FlutterSecureStorage storage) =>
      _secureStorage = storage;

  /// Limpia el estado del singleton para aislar tests.
  @visibleForTesting
  void resetForTesting() {
    _currentUser = null;
    _accessToken = null;
    _refreshToken = null;
    _secureStorage = const FlutterSecureStorage();
  }

  // In-memory cache
  UserEntity? _currentUser;
  String? _accessToken;
  String? _refreshToken;

  // ============ GETTERS ============

  /// Usuario actualmente autenticado (desde cache en memoria)
  UserEntity? get currentUser => _currentUser;

  /// Token de acceso actual (desde cache en memoria)
  String? get accessToken => _accessToken;

  /// Token de refresh actual (desde cache en memoria)
  String? get refreshToken => _refreshToken;

  /// Indica si hay un usuario autenticado
  bool get isAuthenticated => _currentUser != null && _accessToken != null;

  // ============ ASYNC GETTERS ============

  /// Obtiene el token de acceso, primero desde memoria, luego desde storage
  Future<String?> getAccessToken() async {
    if (_accessToken != null) {
      return _accessToken;
    }
    _accessToken = await _secureStorage.read(key: _accessTokenKey);
    return _accessToken;
  }

  /// Obtiene el usuario actual, primero desde memoria, luego desde storage
  Future<UserEntity?> getCurrentUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }
    await loadSession();
    return _currentUser;
  }

  // ============ SESSION MANAGEMENT ============

  /// Carga la sesión desde SecureStorage a memoria.
  /// Llamar al inicio de la aplicación.
  Future<void> loadSession() async {
    try {
      _accessToken = await _secureStorage.read(key: _accessTokenKey);
      _refreshToken = await _secureStorage.read(key: _refreshTokenKey);

      final userDataJson = await _secureStorage.read(key: _userDataKey);
      if (userDataJson != null) {
        _currentUser = UserModel.fromJson(userDataJson);
      }

      AppLogger.auth('Session loaded: isAuthenticated=$isAuthenticated');
    } catch (e) {
      AppLogger.error('Error loading session', e);
      await clearSession();
    }
  }

  /// Guarda la sesión completa (tokens + usuario) después del login.
  Future<void> saveSession({
    required String accessToken,
    String? refreshToken,
    required UserEntity user,
  }) async {
    try {
      // Guardar en memoria
      _accessToken = accessToken;
      _refreshToken = refreshToken;
      _currentUser = user;

      // Persistir en SecureStorage
      await _secureStorage.write(key: _accessTokenKey, value: accessToken);
      if (refreshToken != null) {
        await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
      }

      // Guardar datos del usuario como JSON
      final userModel = UserModel.fromEntity(user);
      await _secureStorage.write(key: _userDataKey, value: userModel.toJson());
      await _secureStorage.write(key: _userIdKey, value: user.id);

      AppLogger.auth('Session saved for user: ${user.email}');
    } catch (e) {
      AppLogger.error('Error saving session', e);
      rethrow;
    }
  }

  /// Limpia la sesión completa (logout).
  Future<void> clearSession() async {
    try {
      // Limpiar memoria
      _currentUser = null;
      _accessToken = null;
      _refreshToken = null;

      // Limpiar SecureStorage
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      await _secureStorage.delete(key: _userDataKey);
      await _secureStorage.delete(key: _userIdKey);

      AppLogger.auth('Session cleared');
    } catch (e) {
      AppLogger.error('Error clearing session', e);
    }
  }

  // ============ USER DATA MANAGEMENT ============

  /// Actualiza los datos del usuario en memoria y storage.
  /// Llamar después de editar el perfil.
  Future<void> updateUser(UserEntity user) async {
    try {
      _currentUser = user;

      // Actualizar en SecureStorage
      final userModel = UserModel.fromEntity(user);
      await _secureStorage.write(key: _userDataKey, value: userModel.toJson());

      AppLogger.auth('User data updated: ${user.email}');
    } catch (e) {
      AppLogger.error('Error updating user', e);
    }
  }

  /// Actualiza solo los tokens (útil para refresh token).
  Future<void> updateTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    try {
      _accessToken = accessToken;
      await _secureStorage.write(key: _accessTokenKey, value: accessToken);

      if (refreshToken != null) {
        _refreshToken = refreshToken;
        await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
      }

      AppLogger.auth('Tokens updated');
    } catch (e) {
      AppLogger.error('Error updating tokens', e);
    }
  }
}
