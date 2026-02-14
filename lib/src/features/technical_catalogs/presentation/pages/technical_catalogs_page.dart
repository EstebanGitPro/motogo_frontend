import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/constants/admin_constants.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/presentation/pages/brand_lines_page.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/presentation/pages/category_lines_page.dart';

/// Main page for Technical Catalogs section.
///
/// Displays a list of available catalog queries.
/// Currently only Brand Lines (HU40) is enabled.
class TechnicalCatalogsPage extends StatelessWidget {
  const TechnicalCatalogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AdminConstants.technicalCatalogsTitle),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // HU40 - Brand Lines (Enabled)
          _CatalogCard(
            icon: Icons.factory,
            title: AdminConstants.catalogBrandLines,
            subtitle: AdminConstants.catalogBrandLinesSubtitle,
            isEnabled: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BrandLinesPage()),
              );
            },
          ),
          const SizedBox(height: 12),

          // HU42 - Brands (Coming Soon)
          const _CatalogCard(
            icon: Icons.label,
            title: AdminConstants.catalogBrands,
            subtitle: AdminConstants.catalogBrandsSubtitle,
            isEnabled: false,
          ),
          const SizedBox(height: 12),

          // Categories (Enabled)
          _CatalogCard(
            icon: Icons.category,
            title: AdminConstants.catalogCategories,
            subtitle: AdminConstants.catalogCategoriesSubtitle,
            isEnabled: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategoryLinesPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // HU41 - Line Categories (Coming Soon)
          const _CatalogCard(
            icon: Icons.folder,
            title: AdminConstants.catalogLineCategories,
            subtitle: AdminConstants.catalogLineCategoriesSubtitle,
            isEnabled: false,
          ),
          const SizedBox(height: 12),

          // HU49 - Engine Ranges (Coming Soon)
          const _CatalogCard(
            icon: Icons.settings,
            title: AdminConstants.catalogEngineRanges,
            subtitle: AdminConstants.catalogEngineRangesSubtitle,
            isEnabled: false,
          ),
        ],
      ),
    );
  }
}

class _CatalogCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isEnabled;
  final VoidCallback? onTap;

  const _CatalogCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isEnabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isEnabled ? 2 : 0,
      color: isEnabled ? Colors.white : Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isEnabled
              ? Colors.blue.withValues(alpha: 0.3)
              : Colors.grey[300]!,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isEnabled ? Colors.blue[50] : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isEnabled ? Colors.blue[700] : Colors.grey[500],
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isEnabled ? Colors.black87 : Colors.grey[600],
          ),
        ),
        subtitle: Text(
          isEnabled ? subtitle : AdminConstants.comingSoon,
          style: TextStyle(
            color: isEnabled ? Colors.grey[600] : Colors.grey[500],
            fontSize: 13,
          ),
        ),
        trailing: isEnabled
            ? const Icon(Icons.chevron_right, color: Colors.blue)
            : Icon(Icons.lock_outline, color: Colors.grey[400], size: 20),
        onTap: isEnabled ? onTap : null,
      ),
    );
  }
}
