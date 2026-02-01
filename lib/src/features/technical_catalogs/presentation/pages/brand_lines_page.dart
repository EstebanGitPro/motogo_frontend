import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/brand_entity.dart';
import 'package:motogo_frontend/src/core/constants/admin_constants.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/entities/brand_line_entity.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/presentation/bloc/brand_lines_bloc.dart';

/// Page for viewing brand lines (HU40).
///
/// First shows a list of brands, then displays lines for the selected brand.
class BrandLinesPage extends StatelessWidget {
  const BrandLinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BrandLinesBloc()..add(const LoadBrands()),
      child: const _BrandLinesView(),
    );
  }
}

class _BrandLinesView extends StatelessWidget {
  const _BrandLinesView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrandLinesBloc, BrandLinesState>(
      builder: (context, state) {
        // Determine app bar title based on state
        String title = AdminConstants.brandLinesTitle;
        bool showBackButton = false;

        if (state is BrandLinesLoadingLines) {
          title = state.brandName;
          showBackButton = true;
        } else if (state is BrandLinesLoadedLines) {
          title = 'Líneas de ${state.brandName}';
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
                      context.read<BrandLinesBloc>().add(
                        const ClearBrandSelection(),
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

  Widget _buildBody(BuildContext context, BrandLinesState state) {
    if (state is BrandLinesLoadingBrands || state is BrandLinesLoadingLines) {
      final message = state is BrandLinesLoadingBrands
          ? AdminConstants.loadingBrands
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

    if (state is BrandLinesError) {
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
                context.read<BrandLinesBloc>().add(const LoadBrands());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (state is BrandLinesLoadedBrands) {
      return _buildBrandsList(context, state.brands);
    }

    if (state is BrandLinesLoadedLines) {
      return _buildLinesList(state.brandName, state.lines);
    }

    return const SizedBox.shrink();
  }

  Widget _buildBrandsList(BuildContext context, List<BrandEntity> brands) {
    if (brands.isEmpty) {
      return const Center(child: Text('No hay marcas disponibles'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            AdminConstants.selectBrandPrompt,
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
            itemCount: brands.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final brand = brands[index];
              return Card(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.factory, color: Colors.blue[700]),
                  ),
                  title: Text(
                    brand.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.read<BrandLinesBloc>().add(
                      LoadBrandLines(brandId: brand.id, brandName: brand.name),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLinesList(String brandName, List<BrandLineEntity> lines) {
    if (lines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              AdminConstants.noLinesFound,
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
              Icon(Icons.factory, color: Colors.blue[700]),
              const SizedBox(width: 12),
              Text(
                '$brandName - ${lines.length} ${AdminConstants.linesFoundCount}',
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
              return Card(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.two_wheeler, color: Colors.green[700]),
                  ),
                  title: Text(
                    line.model,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(line.brandName),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
