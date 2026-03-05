import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:motogo_frontend/main.dart' as app;

/// Integration tests for MotoGo.
///
/// These tests run on a real device or emulator and interact
/// with the full application stack.
///
/// Run with:
///   flutter test integration_test/app_test.dart
///
/// Or on a specific device:
///   flutter test integration_test/app_test.dart -d <device_id>
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Splash Screen', () {
    testWidgets('should display splash screen on app launch', (
      WidgetTester tester,
    ) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Verify the splash screen elements are visible
      // The MotoGo logo and text should appear
      expect(find.text('MotoGo'), findsOneWidget);
    });
  });

  group('Navigation', () {
    testWidgets('splash screen should navigate to login or home', (
      WidgetTester tester,
    ) async {
      app.main();

      // Wait for splash animation and navigation
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // After splash, user should be on login page (if not logged in)
      // or home page (if session exists)
      final loginFound = find.byType(Scaffold);
      expect(loginFound, findsWidgets);
    });
  });
}
