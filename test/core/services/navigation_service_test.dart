import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/services/navigation_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NavigationService', () {
    group('navigatorKey', () {
      test('should be a GlobalKey<NavigatorState>', () {
        // Act
        final key = NavigationService.navigatorKey;

        // Assert
        expect(key, isA<GlobalKey<NavigatorState>>());
      });

      test('should return the same key on multiple accesses', () {
        // Act
        final key1 = NavigationService.navigatorKey;
        final key2 = NavigationService.navigatorKey;

        // Assert
        expect(identical(key1, key2), isTrue);
      });
    });

    group('navigateToLogin', () {
      test('should not throw when called without navigator context', () {
        // Act & Assert
        // When navigatorKey.currentState is null, the method should handle gracefully
        expect(() => NavigationService.navigateToLogin(), returnsNormally);
      });
    });

    group('showSnackBar', () {
      test('should not throw when called without context', () {
        // Act & Assert
        // When navigatorKey.currentContext is null, the method should handle gracefully
        expect(
          () => NavigationService.showSnackBar('Test message'),
          returnsNormally,
        );
      });

      test('should accept empty string message', () {
        expect(() => NavigationService.showSnackBar(''), returnsNormally);
      });

      test('should accept long message', () {
        final longMessage = 'A' * 500;
        expect(
          () => NavigationService.showSnackBar(longMessage),
          returnsNormally,
        );
      });

      test('should accept message with special characters', () {
        expect(
          () => NavigationService.showSnackBar('Error: ¡Algo salió mal! 🚨'),
          returnsNormally,
        );
      });
    });
  });
}
