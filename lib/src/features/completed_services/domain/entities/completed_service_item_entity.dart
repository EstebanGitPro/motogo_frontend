import 'package:equatable/equatable.dart';

/// Entity representing a single service item within a completed service.
///
/// Each completed service contains one or more items, each of which
/// can be independently rated by the motorcycle owner.
class CompletedServiceItemEntity extends Equatable {
  /// Item ID — used in the POST rating path.
  final String id;

  /// Catalog service ID.
  final String serviceId;

  /// Human-readable service name (if available).
  final String? serviceName;

  /// Rating value (1–5) or null if not yet rated.
  final int? rating;

  /// User comment accompanying the rating.
  final String? comment;

  /// ISO date when the rating was submitted.
  final String? ratedAt;

  const CompletedServiceItemEntity({
    required this.id,
    required this.serviceId,
    this.serviceName,
    this.rating,
    this.comment,
    this.ratedAt,
  });

  /// Whether this item has already been rated.
  bool get isRated => rating != null;

  /// Whether this item can still be rated (only if not yet rated).
  bool get canRate => !isRated;

  @override
  List<Object?> get props => [
    id,
    serviceId,
    serviceName,
    rating,
    comment,
    ratedAt,
  ];
}
