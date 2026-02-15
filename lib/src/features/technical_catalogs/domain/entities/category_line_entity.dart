import 'package:equatable/equatable.dart';

/// Entity representing a motorcycle line within a category.
///
/// Used in the Categories catalog to display lines for a selected category.
class CategoryLineEntity extends Equatable {
  final String model;
  final String brand;
  final int engineDisplacement;

  const CategoryLineEntity({
    required this.model,
    required this.brand,
    required this.engineDisplacement,
  });

  @override
  List<Object?> get props => [model, brand, engineDisplacement];
}
