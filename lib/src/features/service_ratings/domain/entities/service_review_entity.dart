import 'package:equatable/equatable.dart';

/// Aggregate summary of all reviews for a specific service type.
class ServiceReviewSummaryEntity extends Equatable {
  final String serviceId;
  final String serviceName;
  final double averageRating;
  final int totalReviews;

  /// Star breakdown: key = star value (1–5), value = count.
  final Map<int, int> breakdown;
  final List<ServiceReviewItemEntity> reviews;

  const ServiceReviewSummaryEntity({
    required this.serviceId,
    required this.serviceName,
    required this.averageRating,
    required this.totalReviews,
    required this.breakdown,
    required this.reviews,
  });

  @override
  List<Object?> get props => [
    serviceId,
    serviceName,
    averageRating,
    totalReviews,
    breakdown,
    reviews,
  ];
}

/// A single review left by a motorcyclist.
class ServiceReviewItemEntity extends Equatable {
  final String reviewerName;
  final int rating;
  final String? comment;
  final DateTime ratedAt;
  final String? motorcycleModel;

  const ServiceReviewItemEntity({
    required this.reviewerName,
    required this.rating,
    this.comment,
    required this.ratedAt,
    this.motorcycleModel,
  });

  /// Initials derived from reviewer name (e.g. "Carlos M." → "CM").
  String get initials {
    final parts = reviewerName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  List<Object?> get props => [
    reviewerName,
    rating,
    comment,
    ratedAt,
    motorcycleModel,
  ];
}
