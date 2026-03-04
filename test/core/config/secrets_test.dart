import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/config/secrets.dart';

void main() {
  group('Secrets', () {
    test('mapboxAccessToken should not be empty (embedded default)', () {
      expect(Secrets.mapboxAccessToken, isNotEmpty);
    });

    test('mapboxAccessToken should start with pk. prefix', () {
      expect(Secrets.mapboxAccessToken, startsWith('pk.'));
    });

    test('isMapboxConfigured should return true when token is set', () {
      expect(Secrets.isMapboxConfigured, isTrue);
    });
  });
}
