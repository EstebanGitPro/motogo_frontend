import 'package:equatable/equatable.dart';

/// Entity representing a day from the days catalog.
class DayEntity extends Equatable {
  /// API value (e.g., "monday", "tuesday")
  final String value;

  /// Display label (e.g., "Lunes", "Martes")
  final String label;

  const DayEntity({required this.value, required this.label});

  @override
  List<Object?> get props => [value, label];
}
