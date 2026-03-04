import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/config/config.dart';

void main() {
  group('Config', () {
    test('baseUrl should not be empty', () {
      expect(Config.baseUrl, isNotEmpty);
    });

    test('baseUrl should be a valid URL', () {
      final uri = Uri.tryParse(Config.baseUrl);
      expect(uri, isNotNull);
      expect(uri!.hasScheme, isTrue);
    });

    test('baseUrl should contain the API version path', () {
      expect(Config.baseUrl, contains('/motogo/api/v1'));
    });

    group('googleMapsDirectionsUrl', () {
      test('should generate correct directions URL', () {
        final url = Config.googleMapsDirectionsUrl(4.6097, -74.0817);
        expect(url, contains('google.com/maps/dir'));
        expect(url, contains('destination=4.6097,-74.0817'));
        expect(url, contains('travelmode=driving'));
      });

      test('should handle negative coordinates', () {
        final url = Config.googleMapsDirectionsUrl(-34.6037, -58.3816);
        expect(url, contains('destination=-34.6037,-58.3816'));
      });
    });

    group('googleMapsSearchUrl', () {
      test('should generate correct search URL', () {
        final url = Config.googleMapsSearchUrl(4.6097, -74.0817);
        expect(url, contains('google.com/maps/search'));
        expect(url, contains('query=4.6097,-74.0817'));
      });

      test('should handle negative coordinates', () {
        final url = Config.googleMapsSearchUrl(-34.6037, -58.3816);
        expect(url, contains('query=-34.6037,-58.3816'));
      });
    });
  });
}
