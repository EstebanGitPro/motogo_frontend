import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/constants/admin_constants.dart';
import 'package:motogo_frontend/src/core/constants/common_constants.dart';
import 'package:motogo_frontend/src/core/widgets/catalog_item_card.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/entities/category_entity.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/entities/category_line_entity.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/presentation/bloc/category_lines_bloc.dart';

/// Page for viewing motorcycle categories and their lines.
///
/// First shows a list of categories, then displays lines for the selected category.
class CategoryLinesPage extends StatelessWidget {
  const CategoryLinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CategoryLinesBloc()..add(const LoadCategories()),
      child: const _CategoryLinesView(),
    );
  }
}

class _CategoryLinesView extends StatelessWidget {
  const _CategoryLinesView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryLinesBloc, CategoryLinesState>(
      builder: (context, state) {
        // Determine app bar title based on state
        String title = AdminConstants.categoryLinesTitle;
        bool showBackButton = false;

        if (state is CategoryLinesLoadingLines) {
          title = state.categoryName;
          showBackButton = true;
        } else if (state is CategoryLinesLoadedLines) {
          title = '${AdminConstants.linesOfPrefix}${state.categoryName}';
          showBackButton = true;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            leading: showBackButton
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      context.read<CategoryLinesBloc>().add(
                        const ClearCategorySelection(),
                      );
                    },
                  )
                : null,
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, CategoryLinesState state) {
    if (state is CategoryLinesLoadingCategories ||
        state is CategoryLinesLoadingLines) {
      final message = state is CategoryLinesLoadingCategories
          ? AdminConstants.loadingCategories
          : AdminConstants.loadingLines;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    if (state is CategoryLinesError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(state.message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.read<CategoryLinesBloc>().add(const LoadCategories());
              },
              icon: const Icon(Icons.refresh),
              label: const Text(CommonConstants.retry),
            ),
          ],
        ),
      );
    }

    if (state is CategoryLinesLoadedCategories) {
      return _buildCategoriesList(context, state.categories);
    }

    if (state is CategoryLinesLoadedLines) {
      return _buildLinesList(state.categoryName, state.lines);
    }

    return const SizedBox.shrink();
  }

  Widget _buildCategoriesList(
    BuildContext context,
    List<CategoryEntity> categories,
  ) {
    if (categories.isEmpty) {
      return const Center(child: Text(AdminConstants.noCategoriesFound));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            AdminConstants.selectCategoryPrompt,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              return CatalogItemCard(
                icon: Icons.category,
                iconBackgroundColor: Colors.blue[50],
                iconColor: Colors.blue[700],
                title: category.name,
                subtitle:
                    '${category.lineCount} ${AdminConstants.categoryLinesFoundCount}',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.read<CategoryLinesBloc>().add(
                    LoadCategoryLines(categoryName: category.name),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLinesList(String categoryName, List<CategoryLineEntity> lines) {
    if (lines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              AdminConstants.noCategoryLinesFound,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.blue[50],
          child: Row(
            children: [
              Icon(Icons.category, color: Colors.blue[700]),
              const SizedBox(width: 12),
              Text(
                '$categoryName - ${lines.length} ${AdminConstants.categoryLinesFoundCount}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lines.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final line = lines[index];
              return CatalogItemCard(
                icon: Icons.two_wheeler,
                iconBackgroundColor: Colors.green[50],
                iconColor: Colors.green[700],
                title: line.model,
                subtitle: '${line.brand} · ${line.engineDisplacement} cc',
              );
            },
          ),
        ),
      ],
    );
  }
}
