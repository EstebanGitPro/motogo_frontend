import 'package:equatable/equatable.dart';

/// Entity representing a service associated with a branch.
///
/// Extends the base service info with branch-specific fields like
/// when it was added and whether it's active.
class BranchServiceEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String serviceType;
  final DateTime? addedAt;
  final bool active;
  final double? averageRating;
  final int totalReviews;

  const BranchServiceEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.serviceType,
    this.addedAt,
    this.active = true,
    this.averageRating,
    this.totalReviews = 0,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    serviceType,
    addedAt,
    active,
    averageRating,
    totalReviews,
  ];
}
