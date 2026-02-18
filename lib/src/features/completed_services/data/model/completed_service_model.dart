import 'package:motogo_frontend/src/features/completed_services/domain/entities/completed_service_entity.dart';

/// Model representing a completed service from the API response.
///
/// Maps JSON from `GET /branches/{branch_id}/completed-services`.
class CompletedServiceModel {
  final String id;
  final String branchId;
  final String? branchName;
  final String motorcycleId;
  final String? diagnosticId;
  final String status;
  final DateTime requestDate;
  final double? quotedPrice;
  final double? finalPrice;
  final String? representativeNotes;
  final List<String> serviceIds;
  final List<String> serviceNames;

  const CompletedServiceModel({
    required this.id,
    required this.branchId,
    this.branchName,
    required this.motorcycleId,
    this.diagnosticId,
    required this.status,
    required this.requestDate,
    this.quotedPrice,
    this.finalPrice,
    this.representativeNotes,
    this.serviceIds = const [],
    this.serviceNames = const [],
  });

  factory CompletedServiceModel.fromJson(Map<String, dynamic> json) {
    // Parse services list to extract service_id values
    final servicesRaw = json['services'] as List<dynamic>? ?? [];
    final serviceIds = servicesRaw
        .map((s) => (s as Map<String, dynamic>)['service_id'] as String?)
        .where((id) => id != null)
        .cast<String>()
        .toList();
    final serviceNames = servicesRaw
        .map((s) => (s as Map<String, dynamic>)['service_name'] as String?)
        .where((name) => name != null)
        .cast<String>()
        .toList();

    return CompletedServiceModel(
      id: json['id'] as String,
      branchId: json['branch_id'] as String,
      branchName: json['branch_name'] as String?,
      motorcycleId: json['motorcycle_id'] as String,
      diagnosticId: json['diagnostic_id'] as String?,
      status: json['status'] as String,
      requestDate: DateTime.parse(json['request_date'] as String),
      quotedPrice: (json['quoted_price'] as num?)?.toDouble(),
      finalPrice: (json['final_price'] as num?)?.toDouble(),
      representativeNotes: json['representative_notes'] as String?,
      serviceIds: serviceIds,
      serviceNames: serviceNames,
    );
  }

  CompletedServiceEntity toEntity() {
    return CompletedServiceEntity(
      id: id,
      branchId: branchId,
      branchName: branchName,
      motorcycleId: motorcycleId,
      diagnosticId: diagnosticId,
      status: status,
      requestDate: requestDate,
      quotedPrice: quotedPrice,
      finalPrice: finalPrice,
      representativeNotes: representativeNotes,
      serviceIds: serviceIds,
      serviceNames: serviceNames,
    );
  }
}
