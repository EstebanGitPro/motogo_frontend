import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/service_ratings/data/models/service_review_model.dart';
import 'package:motogo_frontend/src/features/service_ratings/domain/entities/service_review_entity.dart';

void main() {
  group('ServiceReviewSummaryModel', () {
    test('fromJson parses complete JSON correctly', () {
      final json = <String, dynamic>{
        'service_id': 'svc-001',
        'service_name': 'Cambio de aceite',
        'average_rating': 4.5,
        'total_reviews': 10,
        'breakdown': {'5': 5, '4': 3, '3': 1, '2': 1, '1': 0},
        'reviews': [
          {
            'reviewer_name': 'Carlos Martinez',
            'rating': 5,
            'comment': 'Excelente trabajo',
            'rated_at': '2025-01-15T10:00:00Z',
            'motorcycle_model': 'Yamaha MT-07',
          },
        ],
      };

      final model = ServiceReviewSummaryModel.fromJson(json);

      expect(model.serviceId, 'svc-001');
      expect(model.serviceName, 'Cambio de aceite');
      expect(model.averageRating, 4.5);
      expect(model.totalReviews, 10);
      expect(model.breakdown, {5: 5, 4: 3, 3: 1, 2: 1, 1: 0});
      expect(model.reviews.length, 1);
      expect(model.reviews.first.reviewerName, 'Carlos Martinez');
    });

    test('fromJson handles missing optional fields with defaults', () {
      final json = <String, dynamic>{};

      final model = ServiceReviewSummaryModel.fromJson(json);

      expect(model.serviceId, '');
      expect(model.serviceName, '');
      expect(model.averageRating, 0.0);
      expect(model.totalReviews, 0);
      expect(model.breakdown, <int, int>{});
      expect(model.reviews, isEmpty);
    });

    test('fromJson handles null breakdown and reviews', () {
      final json = <String, dynamic>{
        'service_id': 'svc-002',
        'service_name': 'Revisión general',
        'average_rating': 3.0,
        'total_reviews': 2,
        'breakdown': null,
        'reviews': null,
      };

      final model = ServiceReviewSummaryModel.fromJson(json);

      expect(model.breakdown, <int, int>{});
      expect(model.reviews, isEmpty);
    });

    test('fromJson filters non-parseable breakdown keys', () {
      final json = <String, dynamic>{
        'breakdown': {'abc': 3, '5': 10, '3': 2},
        'reviews': [],
      };

      final model = ServiceReviewSummaryModel.fromJson(json);

      expect(model.breakdown.length, 2);
      expect(model.breakdown[5], 10);
      expect(model.breakdown[3], 2);
    });

    test('fromJson filters non-map entries in reviews list', () {
      final json = <String, dynamic>{
        'breakdown': <String, dynamic>{},
        'reviews': [
          'not_a_map',
          42,
          <String, dynamic>{
            'reviewer_name': 'Ana',
            'rating': 4,
            'rated_at': '2025-01-10T08:00:00Z',
          },
        ],
      };

      final model = ServiceReviewSummaryModel.fromJson(json);

      expect(model.reviews.length, 1);
      expect(model.reviews.first.reviewerName, 'Ana');
    });

    test('is a ServiceReviewSummaryEntity', () {
      final model = ServiceReviewSummaryModel.fromJson(<String, dynamic>{});
      expect(model, isA<ServiceReviewSummaryEntity>());
    });
  });

  group('ServiceReviewItemModel', () {
    test('fromJson parses complete JSON correctly', () {
      final json = <String, dynamic>{
        'reviewer_name': 'Pedro Lopez',
        'rating': 4,
        'comment': 'Buen trabajo',
        'rated_at': '2025-02-10T14:30:00Z',
        'motorcycle_model': 'Honda CB500',
      };

      final model = ServiceReviewItemModel.fromJson(json);

      expect(model.reviewerName, 'Pedro Lopez');
      expect(model.rating, 4);
      expect(model.comment, 'Buen trabajo');
      expect(model.ratedAt, DateTime.parse('2025-02-10T14:30:00Z'));
      expect(model.motorcycleModel, 'Honda CB500');
    });

    test('fromJson handles missing optional fields', () {
      final json = <String, dynamic>{
        'reviewer_name': 'Maria',
        'rating': 3,
        'rated_at': '2025-01-01T00:00:00Z',
      };

      final model = ServiceReviewItemModel.fromJson(json);

      expect(model.comment, isNull);
      expect(model.motorcycleModel, isNull);
    });

    test('fromJson defaults to empty name and 0 rating when null', () {
      final json = <String, dynamic>{};

      final model = ServiceReviewItemModel.fromJson(json);

      expect(model.reviewerName, '');
      expect(model.rating, 0);
    });

    test('fromJson handles invalid date string', () {
      final json = <String, dynamic>{
        'reviewer_name': 'Test',
        'rating': 1,
        'rated_at': 'not-a-date',
      };

      final model = ServiceReviewItemModel.fromJson(json);

      // Should default to DateTime.now() approximation
      expect(model.ratedAt.year, DateTime.now().year);
    });

    test('is a ServiceReviewItemEntity', () {
      final model = ServiceReviewItemModel.fromJson(<String, dynamic>{
        'rated_at': '2025-01-01T00:00:00Z',
      });
      expect(model, isA<ServiceReviewItemEntity>());
    });
  });
}
