import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/service_ratings/data/models/rate_service_request.dart';

void main() {
  group('RateServiceRequest', () {
    test('toJson includes rating', () {
      const request = RateServiceRequest(rating: 4);
      final json = request.toJson();

      expect(json['rating'], 4);
      expect(json.containsKey('comment'), isFalse);
    });

    test('toJson includes comment when provided', () {
      const request = RateServiceRequest(
        rating: 5,
        comment: 'Excelente servicio',
      );
      final json = request.toJson();

      expect(json['rating'], 5);
      expect(json['comment'], 'Excelente servicio');
    });

    test('toJson excludes comment when null', () {
      const request = RateServiceRequest(rating: 3, comment: null);
      final json = request.toJson();

      expect(json.containsKey('comment'), isFalse);
    });

    test('toJson excludes comment when empty', () {
      const request = RateServiceRequest(rating: 2, comment: '');
      final json = request.toJson();

      expect(json.containsKey('comment'), isFalse);
    });
  });
}
