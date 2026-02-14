import 'package:equatable/equatable.dart';

/// Entity representing an engine displacement range from the catalog.
///
/// Used for displaying displacement range options in branch forms.
class DisplacementRangeEntity extends Equatable {
  final String range;

  const DisplacementRangeEntity({required this.range});

  /// Display label with CC range for user clarity.
  String get displayLabel {
    switch (range) {
      case 'BAJO':
        return 'Bajo (50-200cc)';
      case 'MEDIO':
        return 'Medio (200-500cc)';
      case 'ALTO':
        return 'Alto (500cc+)';
      default:
        return range;
    }
  }

  @override
  List<Object?> get props => [range];
}
