/// Enum representing the types of services a user can request.
///
/// Used in the diagnostic request feature to categorize the service needed.
enum ServiceType {
  /// General maintenance (oil change, tune-up, etc.)
  maintenance,

  /// Repair for specific issues or damage
  repair,

  /// Full diagnostic assessment
  diagnostic,

  /// Other services not covered above
  other,
}

/// Extension to provide display labels for ServiceType.
extension ServiceTypeExtension on ServiceType {
  /// Returns the Spanish label for UI display.
  String get label {
    switch (this) {
      case ServiceType.maintenance:
        return 'Mantenimiento';
      case ServiceType.repair:
        return 'Reparación';
      case ServiceType.diagnostic:
        return 'Diagnóstico';
      case ServiceType.other:
        return 'Otro';
    }
  }
}
