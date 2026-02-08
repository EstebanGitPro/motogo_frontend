import 'package:motogo_frontend/src/features/diagnostic/domain/entity/diagnostic_entity.dart';

/// Model for diagnostic API responses.
class DiagnosticModel {
  final String id;
  final String motorcycleId;
  final String? branchId;
  final String problemDescription;
  final String? status;
  final String? serviceType;
  final String createdAt;

  const DiagnosticModel({
    required this.id,
    required this.motorcycleId,
    this.branchId,
    required this.problemDescription,
    this.status,
    this.serviceType,
    required this.createdAt,
  });

  factory DiagnosticModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final source = data ?? json;

    return DiagnosticModel(
      id: source['id'] as String? ?? '',
      motorcycleId: source['motorcycle_id'] as String? ?? '',
      branchId: source['branch_id'] as String?,
      problemDescription: source['problem_description'] as String? ?? '',
      status: source['status'] as String?,
      serviceType: source['service_type'] as String?,
      createdAt: source['created_at'] as String? ?? '',
    );
  }

  /// Factory for parsing a single item from a list response (no wrapper).
  factory DiagnosticModel.fromDataJson(Map<String, dynamic> json) {
    return DiagnosticModel(
      id: json['id'] as String? ?? '',
      motorcycleId: json['motorcycle_id'] as String? ?? '',
      branchId: json['branch_id'] as String?,
      problemDescription: json['problem_description'] as String? ?? '',
      status: json['status'] as String?,
      serviceType: json['service_type'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  DiagnosticEntity toEntity() {
    return DiagnosticEntity(
      id: id,
      motorcycleId: motorcycleId,
      branchId: branchId,
      problemDescription: problemDescription,
      status: status,
      serviceType: serviceType,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }

  /// Converts the model to a map for POST/PUT requests.
  Map<String, dynamic> toMap() {
    return {
      'problem_description': problemDescription,
      if (branchId != null) 'branch_id': branchId,
      if (serviceType != null) 'service_type': serviceType,
    };
  }
}
