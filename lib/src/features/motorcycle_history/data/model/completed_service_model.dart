import 'package:motogo_frontend/src/features/motorcycle_history/domain/entity/completed_service_entity.dart';

/// Model for completed service API responses.
class CompletedServiceModel {
  final String id;
  final String? diagnosticId;
  final String serviceName;
  final String status;
  final double? quotedPrice;
  final double? finalPrice;
  final String? representativeNotes;
  final String date;

  const CompletedServiceModel({
    required this.id,
    this.diagnosticId,
    required this.serviceName,
    required this.status,
    this.quotedPrice,
    this.finalPrice,
    this.representativeNotes,
    required this.date,
  });

  factory CompletedServiceModel.fromJson(Map<String, dynamic> json) {
    return CompletedServiceModel(
      id: json['id'] as String? ?? '',
      diagnosticId: json['diagnostic_id'] as String?,
      serviceName: json['service_name'] as String? ?? '',
      status: json['status'] as String? ?? '',
      quotedPrice: (json['quoted_price'] as num?)?.toDouble(),
      finalPrice: (json['final_price'] as num?)?.toDouble(),
      representativeNotes: json['representative_notes'] as String?,
      date: json['date'] as String? ?? '',
    );
  }

  CompletedServiceEntity toEntity() {
    return CompletedServiceEntity(
      id: id,
      diagnosticId: diagnosticId,
      serviceName: serviceName,
      status: status,
      quotedPrice: quotedPrice,
      finalPrice: finalPrice,
      representativeNotes: representativeNotes,
      date: DateTime.tryParse(date) ?? DateTime.now(),
    );
  }
}
