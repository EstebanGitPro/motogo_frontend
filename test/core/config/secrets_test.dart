import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/config/secrets.dart';

void main() {
  group('Secrets', () {
    test(
      'mapboxAccessToken is empty when MAPBOX_ACCESS_TOKEN is not provided via --dart-define',
      () {
        expect(Secrets.mapboxAccessToken, isEmpty);
      },
    );

    test('isMapboxConfigured returns false when token is empty', () {
      expect(Secrets.isMapboxConfigured, isFalse);
    });
  });
}
