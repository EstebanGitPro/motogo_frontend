import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/entities/motorcycle_entity.dart';
import 'package:motogo_frontend/src/features/request_diagnostic/domain/enums/service_type.dart';

/// Entity representing a diagnostic request to be sent to a branch.
///
/// Contains all the information needed to generate a WhatsApp message
/// and upload evidence photos.
class DiagnosticRequestEntity extends Equatable {
  /// The motorcycle for which the diagnostic is requested.
  final MotorcycleEntity motorcycle;

  /// Description of the problem or symptoms.
  final String problemDescription;

  /// Photos to upload as evidence (max 4).
  final List<File> photos;

  /// Types of service requested.
  final Set<ServiceType> serviceTypes;

  /// Target branch name.
  final String branchName;

  /// Target branch phone number.
  final String branchPhone;

  const DiagnosticRequestEntity({
    required this.motorcycle,
    required this.problemDescription,
    required this.photos,
    required this.serviceTypes,
    required this.branchName,
    required this.branchPhone,
  });

  /// Maximum number of photos allowed.
  static const int maxPhotos = 4;

  /// Generates the WhatsApp message text.
  String generateWhatsAppMessage() {
    final serviceLabels = serviceTypes.map((t) => t.label).join(', ');
    final motoInfo = motorcycle.licensePlate;
    final year = motorcycle.year?.toString() ?? 'N/A';

    return '''
Hola $branchName, solicito diagnóstico para mi moto:
Placa: $motoInfo
Año: $year
Problema: $problemDescription
Tipo de servicio: $serviceLabels

Fotos adjuntadas en la app MotosGo.
''';
  }

  @override
  List<Object?> get props => [
    motorcycle,
    problemDescription,
    photos,
    serviceTypes,
    branchName,
    branchPhone,
  ];
}
