import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/routes/routes.dart';

/// Global navigation service for app-wide navigation.
///
/// Used by AuthInterceptor to redirect to login when session expires.
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Navigates to login and clears the navigation stack.
  ///
  /// Used when refresh token fails and user must re-authenticate.
  static void navigateToLogin() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      Routes.login,
      (route) => false,
    );
  }

  /// Shows a snackbar message globally.
  static void showSnackBar(String message) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
    }
  }
}
