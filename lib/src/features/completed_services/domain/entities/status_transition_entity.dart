import 'package:equatable/equatable.dart';

/// Entity representing a service status transition record.
///
/// Tracks the history of status changes for a completed service.
class StatusTransitionEntity extends Equatable {
  final String id;
  final String? previousStatus;
  final String newStatus;
  final String createdBy;
  final DateTime createdAt;

  const StatusTransitionEntity({
    required this.id,
    this.previousStatus,
    required this.newStatus,
    required this.createdBy,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    previousStatus,
    newStatus,
    createdBy,
    createdAt,
  ];
}
