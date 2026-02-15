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
        final instance1 = LocationService.instance;
        final instance2 = LocationService.instance;

        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('getPositionStream', () {
      test('should be callable with default parameter', () {
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
        expect(() => service.stopListening(), returnsNormally);
      });

      test('should be safe to call multiple times', () {
        expect(() {
          service.stopListening();
          service.stopListening();
          service.stopListening();
        }, returnsNormally);
      });
    });
  });
}
