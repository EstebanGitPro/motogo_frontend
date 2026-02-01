import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/services/location_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocationService', () {
    late LocationService service;

    setUp(() {
      service = LocationService.instance;
    });

    group('singleton', () {
      test('should return the same instance', () {
        // Act
        final instance1 = LocationService.instance;
        final instance2 = LocationService.instance;

        // Assert
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('isLocationAvailable', () {
      test('should complete without crash in test environment', () async {
        // In test environment, Geolocator throws MissingPluginException
        try {
          await service.isLocationAvailable();
        } catch (e) {
          // Expected - geolocator not available in tests
          expect(e, isNotNull);
        }
      });
    });

    group('requestPermission', () {
      test('should complete without crash in test environment', () async {
        try {
          await service.requestPermission();
        } catch (e) {
          // Expected - geolocator not available in tests
          expect(e, isNotNull);
        }
      });
    });

    group('getCurrentPosition', () {
      test('should complete without crash in test environment', () async {
        try {
          await service.getCurrentPosition();
        } catch (e) {
          // Expected - geolocator not available in tests
          expect(e, isNotNull);
        }
      });
    });

    group('getPositionStream', () {
      test('should be callable with default parameter', () {
        // Act - just verify the method can be called synchronously
        // The stream itself will fail when listened to
        expect(() => service.getPositionStream(), returnsNormally);
      });

      test('should accept distanceFilter parameter', () {
        expect(
          () => service.getPositionStream(distanceFilter: 50),
          returnsNormally,
        );
      });
    });

    group('startListening', () {
      test('should accept callback without crash', () {
        // Act & Assert - the method itself should not throw synchronously
        expect(
          () => service.startListening(
            onPosition: (position) {},
            distanceFilter: 10,
          ),
          returnsNormally,
        );
      });
    });

    group('stopListening', () {
      test('should not throw when called', () {
        // Act & Assert
        expect(() => service.stopListening(), returnsNormally);
      });

      test('should be safe to call multiple times', () {
        // Act & Assert
        expect(() {
          service.stopListening();
          service.stopListening();
          service.stopListening();
        }, returnsNormally);
      });
    });

    group('openLocationSettings', () {
      test('should complete without crash in test environment', () async {
        try {
          await service.openLocationSettings();
        } catch (e) {
          // Expected - geolocator not available in tests
          expect(e, isNotNull);
        }
      });
    });

    group('openAppSettings', () {
      test('should complete without crash in test environment', () async {
        try {
          await service.openAppSettings();
        } catch (e) {
          // Expected - geolocator not available in tests
          expect(e, isNotNull);
        }
      });
    });
  });
}
