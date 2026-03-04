import 'package:motogo_frontend/src/features/completed_services/data/model/completed_service_item_model.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/entities/completed_service_entity.dart';

/// Model representing a completed service from the API response.
///
/// Maps JSON from `GET /branches/{branch_id}/completed-services`
/// and `GET /motorcycles/{motorcycle_id}/completed-services`.
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
  final List<CompletedServiceItemModel> services;

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
    this.services = const [],
  });

  factory CompletedServiceModel.fromJson(Map<String, dynamic> json) {
    final servicesRaw = json['services'] as List<dynamic>? ?? [];
    final serviceItems = servicesRaw
        .map(
          (s) => CompletedServiceItemModel.fromJson(s as Map<String, dynamic>),
        )
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
      services: serviceItems,
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
      services: services.map((s) => s.toEntity()).toList(),
    );
  }
}
