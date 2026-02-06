/// Evidence angle categories for motorcycle photos.
///
/// These must match the backend schema exactly (uppercase).
enum EvidenceAngle {
  frontal('FRONTAL', 'Frontal'),
  lateral('LATERAL', 'Lateral'),
  rear('REAR', 'Trasera');

  final String value;
  final String label;

  const EvidenceAngle(this.value, this.label);

  /// Get angle from API value.
  static EvidenceAngle? fromValue(String? value) {
    if (value == null) return null;
    return EvidenceAngle.values.cast<EvidenceAngle?>().firstWhere(
      (e) => e?.value == value,
      orElse: () => null,
    );
  }
}
