import 'package:flutter/foundation.dart';

/// Centralized logger for the application.
///
/// Only logs in debug mode. In release builds, all logs are no-ops.
/// This follows Clean Architecture by centralizing logging concerns.
class AppLogger {
  AppLogger._();

  /// Log debug message. Only prints in debug mode.
  static void debug(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  /// Log error message with optional error object.
  static void error(String message, [Object? error]) {
    if (kDebugMode) {
      debugPrint('❌ $message');
      if (error != null) {
        debugPrint('   Error: $error');
      }
    }
  }

  /// Log network-related message.
  static void network(String message) {
    if (kDebugMode) {
      debugPrint('🌐 $message');
    }
  }

  /// Log authentication-related message.
  static void auth(String message) {
    if (kDebugMode) {
      debugPrint('🔐 $message');
    }
  }
}
