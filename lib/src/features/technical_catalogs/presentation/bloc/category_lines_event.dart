part of 'category_lines_bloc.dart';

/// Events for the CategoryLinesBloc.
abstract class CategoryLinesEvent extends Equatable {
  const CategoryLinesEvent();

  @override
  List<Object?> get props => [];
}

/// Load all categories.
class LoadCategories extends CategoryLinesEvent {
  const LoadCategories();
}

/// Load lines for a specific category.
class LoadCategoryLines extends CategoryLinesEvent {
  final String categoryName;

  const LoadCategoryLines({required this.categoryName});

  @override
  List<Object?> get props => [categoryName];
}

/// Clear selection and go back to category list.
class ClearCategorySelection extends CategoryLinesEvent {
  const ClearCategorySelection();
}
