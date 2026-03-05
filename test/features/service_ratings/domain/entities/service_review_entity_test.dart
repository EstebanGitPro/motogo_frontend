import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/service_ratings/domain/entities/service_review_entity.dart';

void main() {
  group('ServiceReviewSummaryEntity', () {
    test('props includes all fields', () {
      const entity = ServiceReviewSummaryEntity(
        serviceId: 'svc-001',
        serviceName: 'Cambio de aceite',
        averageRating: 4.5,
        totalReviews: 10,
        breakdown: {5: 5, 4: 3, 3: 1, 2: 1, 1: 0},
        reviews: [],
      );

      expect(entity.props, [
        'svc-001',
        'Cambio de aceite',
        4.5,
        10,
        {5: 5, 4: 3, 3: 1, 2: 1, 1: 0},
        <ServiceReviewItemEntity>[],
      ]);
    });

    test('two entities with same values are equal', () {
      const entity1 = ServiceReviewSummaryEntity(
        serviceId: 'svc-001',
        serviceName: 'Test',
        averageRating: 4.0,
        totalReviews: 5,
        breakdown: {},
        reviews: [],
      );
      const entity2 = ServiceReviewSummaryEntity(
        serviceId: 'svc-001',
        serviceName: 'Test',
        averageRating: 4.0,
        totalReviews: 5,
        breakdown: {},
        reviews: [],
      );

      expect(entity1, equals(entity2));
    });

    test('two entities with different values are not equal', () {
      const entity1 = ServiceReviewSummaryEntity(
        serviceId: 'svc-001',
        serviceName: 'Test',
        averageRating: 4.0,
        totalReviews: 5,
        breakdown: {},
        reviews: [],
      );
      const entity2 = ServiceReviewSummaryEntity(
        serviceId: 'svc-002',
        serviceName: 'Test',
        averageRating: 4.0,
        totalReviews: 5,
        breakdown: {},
        reviews: [],
      );

      expect(entity1, isNot(equals(entity2)));
    });
  });

  group('ServiceReviewItemEntity', () {
    test('props includes all fields', () {
      final ratedAt = DateTime(2025, 1, 15, 10, 0);
      final entity = ServiceReviewItemEntity(
        reviewerName: 'Carlos Martinez',
        rating: 5,
        comment: 'Excelente',
        ratedAt: ratedAt,
        motorcycleModel: 'Yamaha MT-07',
      );

      expect(entity.props, [
        'Carlos Martinez',
        5,
        'Excelente',
        ratedAt,
        'Yamaha MT-07',
      ]);
    });

    test('initials returns two letters for two-word name', () {
      final entity = ServiceReviewItemEntity(
        reviewerName: 'Carlos Martinez',
        rating: 5,
        ratedAt: DateTime(2025),
      );

      expect(entity.initials, 'CM');
    });

    test('initials returns one letter for single-word name', () {
      final entity = ServiceReviewItemEntity(
        reviewerName: 'Carlos',
        rating: 5,
        ratedAt: DateTime(2025),
      );

      expect(entity.initials, 'C');
    });

    test('initials handles lowercase names', () {
      final entity = ServiceReviewItemEntity(
        reviewerName: 'ana beltrán',
        rating: 4,
        ratedAt: DateTime(2025),
      );

      expect(entity.initials, 'AB');
    });

    test('two entities with same values are equal', () {
      final ratedAt = DateTime(2025, 1, 15);
      final entity1 = ServiceReviewItemEntity(
        reviewerName: 'Test',
        rating: 4,
        ratedAt: ratedAt,
      );
      final entity2 = ServiceReviewItemEntity(
        reviewerName: 'Test',
        rating: 4,
        ratedAt: ratedAt,
      );

      expect(entity1, equals(entity2));
    });

    test('nullable fields default to null', () {
      final entity = ServiceReviewItemEntity(
        reviewerName: 'Test',
        rating: 3,
        ratedAt: DateTime(2025),
      );

      expect(entity.comment, isNull);
      expect(entity.motorcycleModel, isNull);
    });
  });
}
