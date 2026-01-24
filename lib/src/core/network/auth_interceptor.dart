import 'dart:async';

import 'package:dio/dio.dart';
import 'package:motogo_frontend/src/core/constants/debug_messages.dart';
import 'package:motogo_frontend/src/core/network/refresh_token_data_source.dart';
import 'package:motogo_frontend/src/core/services/navigation_service.dart';
import 'package:motogo_frontend/src/core/user/user_session_manager.dart';
import 'package:motogo_frontend/src/core/utils/app_logger.dart';

/// Dio interceptor that handles authentication and token refresh.
///
/// Responsibilities:
/// - Adds Authorization header to all requests
/// - Intercepts 401 responses and attempts token refresh
/// - Queues pending requests during refresh to avoid multiple refresh calls
/// - Redirects to login if refresh token is expired
class AuthInterceptor extends Interceptor {
  final RefreshTokenDataSource _refreshDataSource;

  // Lock mechanism to prevent multiple simultaneous refresh attempts
  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  AuthInterceptor(this._refreshDataSource);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add access token to request headers
    final token = await UserSessionManager.instance.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only handle 401 Unauthorized errors
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Skip refresh for auth endpoints to avoid loops
    final path = err.requestOptions.path;
    if (path.contains('/auth/login') || path.contains('/auth/refresh')) {
      return handler.next(err);
    }

    AppLogger.auth(DebugMessages.tokenRefreshStart);

    // Try to refresh the token
    final refreshSuccess = await _attemptTokenRefresh();

    if (refreshSuccess) {
      // Retry the original request with the new token
      try {
        final retryResponse = await _retryRequest(err.requestOptions);
        return handler.resolve(retryResponse);
      } catch (retryError) {
        AppLogger.error(DebugMessages.retryFailed, retryError);
        return handler.next(err);
      }
    } else {
      // Refresh failed - session is expired
      AppLogger.auth(DebugMessages.redirectingToLogin);
      await _handleSessionExpired();
      return handler.next(err);
    }
  }

  /// Attempts to refresh the access token.
  ///
  /// Uses a lock to prevent multiple simultaneous refresh attempts.
  /// Other requests wait for the refresh to complete.
  Future<bool> _attemptTokenRefresh() async {
    // If already refreshing, wait for the result
    if (_isRefreshing) {
      AppLogger.auth(DebugMessages.tokenRefreshWaiting);
      return await _refreshCompleter?.future ?? false;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      final refreshToken = UserSessionManager.instance.refreshToken;

      if (refreshToken == null) {
        AppLogger.auth(DebugMessages.noRefreshToken);
        _completeRefresh(false);
        return false;
      }

      final result = await _refreshDataSource.refreshToken(refreshToken);

      if (result.isRight) {
        final tokenResponse = result.right;

        // Update tokens in session manager
        await UserSessionManager.instance.updateTokens(
          accessToken: tokenResponse.accessToken,
          refreshToken: tokenResponse.refreshToken,
        );

        AppLogger.auth(DebugMessages.tokenRefreshSuccess);
        _completeRefresh(true);
        return true;
      } else {
        AppLogger.error(
          '${DebugMessages.tokenRefreshFailed}: ${result.left.message}',
        );
        _completeRefresh(false);
        return false;
      }
    } catch (e) {
      AppLogger.error(DebugMessages.tokenRefreshError, e);
      _completeRefresh(false);
      return false;
    }
  }

  void _completeRefresh(bool success) {
    _isRefreshing = false;
    _refreshCompleter?.complete(success);
    _refreshCompleter = null;
  }

  /// Retries the original request with the new access token.
  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) async {
    final newToken = await UserSessionManager.instance.getAccessToken();

    // Create a new Dio instance for the retry to avoid interceptor loops
    final retryDio = Dio();

    final options = Options(
      method: requestOptions.method,
      headers: {...requestOptions.headers, 'Authorization': 'Bearer $newToken'},
    );

    return retryDio.request(
      requestOptions.path.startsWith('http')
          ? requestOptions.path
          : '${requestOptions.baseUrl}${requestOptions.path}',
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  /// Handles session expiration by clearing session and redirecting to login.
  /// Note: We don't show a SnackBar here - the error propagates to the UI
  /// which is responsible for displaying the appropriate error message.
  /// This prevents duplicate SnackBars when errors are handled by BlocConsumers.
  Future<void> _handleSessionExpired() async {
    await UserSessionManager.instance.clearSession();
    NavigationService.navigateToLogin();
  }
}
