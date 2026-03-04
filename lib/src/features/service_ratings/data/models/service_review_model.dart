import 'package:motogo_frontend/src/features/service_ratings/domain/entities/service_review_entity.dart';

/// Model for parsing the service reviews API response.
///
/// Expected JSON (inside `data`):
/// ```json
/// {
///   "service_id": "xYz123",
///   "service_name": "Cambio de aceite",
///   "average_rating": 4.7,
///   "total_reviews": 28,
///   "breakdown": { "5": 18, "4": 7, "3": 2, "2": 1, "1": 0 },
///   "reviews": [...]
/// }
/// ```
class ServiceReviewSummaryModel extends ServiceReviewSummaryEntity {
  const ServiceReviewSummaryModel({
    required super.serviceId,
    required super.serviceName,
    required super.averageRating,
    required super.totalReviews,
    required super.breakdown,
    required super.reviews,
  });

  factory ServiceReviewSummaryModel.fromJson(Map<String, dynamic> json) {
    // Parse breakdown: keys are string "1"-"5", values are counts
    final rawBreakdown = json['breakdown'] as Map<String, dynamic>? ?? {};
    final breakdown = <int, int>{};
    for (final entry in rawBreakdown.entries) {
      final star = int.tryParse(entry.key);
      if (star != null) {
        breakdown[star] = (entry.value as num?)?.toInt() ?? 0;
      }
    }

    // Parse reviews list
    final rawReviews = json['reviews'] as List<dynamic>? ?? [];
    final reviews = rawReviews
        .whereType<Map<String, dynamic>>()
        .map(ServiceReviewItemModel.fromJson)
        .toList();

    return ServiceReviewSummaryModel(
      serviceId: json['service_id'] as String? ?? '',
      serviceName: json['service_name'] as String? ?? '',
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      breakdown: breakdown,
      reviews: reviews,
    );
  }
}

/// Model for parsing individual review items.
class ServiceReviewItemModel extends ServiceReviewItemEntity {
  const ServiceReviewItemModel({
    required super.reviewerName,
    required super.rating,
    super.comment,
    required super.ratedAt,
    super.motorcycleModel,
  });

  factory ServiceReviewItemModel.fromJson(Map<String, dynamic> json) {
    return ServiceReviewItemModel(
      reviewerName: json['reviewer_name'] as String? ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment'] as String?,
      ratedAt:
          DateTime.tryParse(json['rated_at'] as String? ?? '') ??
          DateTime.now(),
      motorcycleModel: json['motorcycle_model'] as String?,
    );
  }
}
