import 'package:equatable/equatable.dart';

/// Entity representing a motorcycle diagnostic request.
class DiagnosticEntity extends Equatable {
  final String id;
  final String motorcycleId;
  final String? branchId;
  final String problemDescription;
  final String? status;
  final String? serviceType;
  final DateTime createdAt;

  const DiagnosticEntity({
    required this.id,
    required this.motorcycleId,
    this.branchId,
    required this.problemDescription,
    this.status,
    this.serviceType,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    motorcycleId,
    branchId,
    problemDescription,
    status,
    serviceType,
    createdAt,
  ];
}
