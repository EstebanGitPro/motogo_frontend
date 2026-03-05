import 'package:motogo_frontend/src/features/completed_services/domain/entities/completed_service_item_entity.dart';

/// Model for parsing a completed service item from JSON.
///
/// Maps the `services` array items returned by
/// `GET /motorcycles/:id/completed-services` and
/// `GET /branches/:id/completed-services`.
class CompletedServiceItemModel extends CompletedServiceItemEntity {
  const CompletedServiceItemModel({
    required super.id,
    required super.serviceId,
    super.serviceName,
    super.rating,
    super.comment,
    super.ratedAt,
  });

  /// Creates a [CompletedServiceItemModel] from a JSON map.
  ///
  /// Expected JSON:
  /// ```json
  /// {
  ///   "id": "wnxEGqbfAq8...",
  ///   "service_id": "yRxBXP4tD1N...",
  ///   "service_name": "Cambio de aceite",
  ///   "rating": 5,
  ///   "comment": "Excelente servicio",
  ///   "rated_at": "2026-02-17"
  /// }
  /// ```
  factory CompletedServiceItemModel.fromJson(Map<String, dynamic> json) {
    return CompletedServiceItemModel(
      id: json['id'] as String,
      serviceId: json['service_id'] as String,
      serviceName: json['service_name'] as String?,
      rating: json['rating'] as int?,
      comment: json['comment'] as String?,
      ratedAt: json['rated_at'] as String?,
    );
  }

  /// Converts to domain entity.
  CompletedServiceItemEntity toEntity() {
    return CompletedServiceItemEntity(
      id: id,
      serviceId: serviceId,
      serviceName: serviceName,
      rating: rating,
      comment: comment,
      ratedAt: ratedAt,
    );
  }
}
