part of 'category_lines_bloc.dart';

/// States for the CategoryLinesBloc.
abstract class CategoryLinesState extends Equatable {
  const CategoryLinesState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
class CategoryLinesInitial extends CategoryLinesState {
  const CategoryLinesInitial();
}

/// Loading categories list.
class CategoryLinesLoadingCategories extends CategoryLinesState {
  const CategoryLinesLoadingCategories();
}

/// Categories loaded successfully.
class CategoryLinesLoadedCategories extends CategoryLinesState {
  final List<CategoryEntity> categories;

  const CategoryLinesLoadedCategories(this.categories);

  @override
  List<Object?> get props => [categories];
}

/// Loading lines for a category.
class CategoryLinesLoadingLines extends CategoryLinesState {
  final String categoryName;

  const CategoryLinesLoadingLines(this.categoryName);

  @override
  List<Object?> get props => [categoryName];
}

/// Lines loaded successfully.
class CategoryLinesLoadedLines extends CategoryLinesState {
  final String categoryName;
  final List<CategoryLineEntity> lines;

  const CategoryLinesLoadedLines({
    required this.categoryName,
    required this.lines,
  });

  @override
  List<Object?> get props => [categoryName, lines];
}

/// Error state.
class CategoryLinesError extends CategoryLinesState {
  final String message;

  const CategoryLinesError(this.message);

  @override
  List<Object?> get props => [message];
}
