import 'package:equatable/equatable.dart';

/// Entity representing a motorcycle category.
///
/// Used in the Categories catalog to display category names and line counts.
class CategoryEntity extends Equatable {
  final String name;
  final int lineCount;

  const CategoryEntity({required this.name, required this.lineCount});

  @override
  List<Object?> get props => [name, lineCount];
}
