import 'package:equatable/equatable.dart';

/// Entity representing a rating range option.
///
/// Used to define the allowed rating values (e.g. 1-5 stars)
/// and their human-readable labels.
class RatingRangeEntity extends Equatable {
  final int value;
  final String label;

  const RatingRangeEntity({required this.value, required this.label});

  @override
  List<Object?> get props => [value, label];
}
