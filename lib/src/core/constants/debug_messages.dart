/// Mensajes de log centralizados para debug.
///
/// Estos mensajes solo aparecen en modo debug y son útiles
/// para diagnosticar problemas durante el desarrollo.
class DebugMessages {
  // ============ AUTH INTERCEPTOR ============

  /// Token refresh - inicio
  static const String tokenRefreshStart =
      '🔄 Received 401, attempting token refresh...';

  /// Token refresh - esperando
  static const String tokenRefreshWaiting = '⏳ Waiting for ongoing refresh...';

  /// Token refresh - sin refresh token
  static const String noRefreshToken = '❌ No refresh token available';

  /// Token refresh - exitoso
  static const String tokenRefreshSuccess = '✅ Token refreshed successfully';

  /// Token refresh - fallido (con placeholder para mensaje)
  static const String tokenRefreshFailed = '❌ Refresh failed';

  /// Token refresh - error
  static const String tokenRefreshError = '❌ Refresh error';

  /// Token refresh - reintento fallido
  static const String retryFailed = '❌ Retry failed after refresh';

  /// Token refresh - redirigiendo a login
  static const String redirectingToLogin =
      '❌ Token refresh failed, redirecting to login';

  // ============ DATASOURCES ============

  /// Creando branch
  static const String creatingBranch = '📤 Creating branch with payload';

  /// Actualizando branch
  static const String updatingBranch = '📤 Updating branch';

  /// Eliminando branch
  static const String deletingBranch = '🗑️ Deleting branch';

  /// Eliminando cuenta
  static const String deletingAccount = '🗑️ Deleting user account';

  // ============ GEOCODING ============

  /// Geocoding fallido
  static const String geocodingFailed =
      'No se pudo obtener la ubicación. Intenta más tarde.';

  /// Error inesperado
  static const String unexpectedError =
      'Ocurrió un error inesperado. Intenta más tarde.';

  /// Geocoding en progreso
  static const String loadingLocation = '📍 Cargando ubicación...';
}
