import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/entities/category_entity.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/entities/category_line_entity.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/usecases/get_categories_usecase.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/usecases/get_category_lines_usecase.dart';

part 'category_lines_event.dart';
part 'category_lines_state.dart';

/// BLoC for managing motorcycle categories catalog.
///
/// Handles loading categories list and fetching lines per category.
class CategoryLinesBloc extends Bloc<CategoryLinesEvent, CategoryLinesState> {
  final GetCategoriesUseCase _getCategoriesUseCase;
  final GetCategoryLinesUseCase _getCategoryLinesUseCase;

  CategoryLinesBloc({
    GetCategoriesUseCase? getCategoriesUseCase,
    GetCategoryLinesUseCase? getCategoryLinesUseCase,
  }) : _getCategoriesUseCase =
           getCategoriesUseCase ?? InjectorApp.resolve<GetCategoriesUseCase>(),
       _getCategoryLinesUseCase =
           getCategoryLinesUseCase ??
           InjectorApp.resolve<GetCategoryLinesUseCase>(),
       super(const CategoryLinesInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<LoadCategoryLines>(_onLoadCategoryLines);
    on<ClearCategorySelection>(_onClearCategorySelection);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryLinesState> emit,
  ) async {
    emit(const CategoryLinesLoadingCategories());

    final result = await _getCategoriesUseCase();

    result.fold(
      (error) => emit(CategoryLinesError(error.message)),
      (categories) => emit(CategoryLinesLoadedCategories(categories)),
    );
  }

  Future<void> _onLoadCategoryLines(
    LoadCategoryLines event,
    Emitter<CategoryLinesState> emit,
  ) async {
    emit(CategoryLinesLoadingLines(event.categoryName));

    final result = await _getCategoryLinesUseCase(event.categoryName);

    result.fold(
      (error) => emit(CategoryLinesError(error.message)),
      (lines) => emit(
        CategoryLinesLoadedLines(
          categoryName: event.categoryName,
          lines: lines,
        ),
      ),
    );
  }

  void _onClearCategorySelection(
    ClearCategorySelection event,
    Emitter<CategoryLinesState> emit,
  ) {
    add(const LoadCategories());
  }
}
