import 'package:motogo_frontend/src/features/completed_services/domain/entities/status_transition_entity.dart';

/// Model representing a status transition from the API response.
///
/// Maps JSON from `GET /completed-services/{id}/transitions`.
class StatusTransitionModel {
  final String id;
  final String? previousStatus;
  final String newStatus;
  final String createdBy;
  final DateTime createdAt;

  const StatusTransitionModel({
    required this.id,
    this.previousStatus,
    required this.newStatus,
    required this.createdBy,
    required this.createdAt,
  });

  factory StatusTransitionModel.fromJson(Map<String, dynamic> json) {
    return StatusTransitionModel(
      id: json['id'] as String,
      previousStatus: json['previous_status'] as String?,
      newStatus: json['new_status'] as String,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  StatusTransitionEntity toEntity() {
    return StatusTransitionEntity(
      id: id,
      previousStatus: previousStatus,
      newStatus: newStatus,
      createdBy: createdBy,
      createdAt: createdAt,
    );
  }
}
