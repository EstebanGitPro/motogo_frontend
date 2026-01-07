import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/brand_entity.dart';

/// Widget for selecting multiple motorcycle brands using chips.
///
/// Displays brand names from the API but stores brand IDs for persistence.
class BrandsSelector extends StatelessWidget {
  /// List of available brands loaded from the API.
  final List<BrandEntity> availableBrands;

  /// List of selected brand IDs.
  final List<String> selectedBrandIds;

  /// Callback when brand selection changes.
  final ValueChanged<List<String>> onChanged;

  /// Whether the widget is enabled for interaction.
  final bool enabled;

  /// Whether brands are currently loading.
  final bool isLoading;

  /// Optional error message to display.
  final String? errorMessage;

  const BrandsSelector({
    super.key,
    required this.availableBrands,
    required this.selectedBrandIds,
    required this.onChanged,
    this.enabled = true,
    this.isLoading = false,
    this.errorMessage,
  });

  void _toggleBrand(String brandId) {
    if (!enabled) return;

    final newList = List<String>.from(selectedBrandIds);
    if (newList.contains(brandId)) {
      newList.remove(brandId);
    } else {
      newList.add(brandId);
    }
    onChanged(newList);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Marcas que maneja',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        // Loading state
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          )
        // Error state
        else if (errorMessage != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: TextStyle(color: Colors.red[700], fontSize: 13),
                  ),
                ),
              ],
            ),
          )
        // Normal state with brands
        else if (availableBrands.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No hay marcas disponibles',
                    style: TextStyle(color: Colors.orange[700], fontSize: 13),
                  ),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableBrands.map((brand) {
              final isSelected = selectedBrandIds.contains(brand.id);
              return FilterChip(
                label: Text(brand.name),
                selected: isSelected,
                onSelected: enabled ? (_) => _toggleBrand(brand.id) : null,
                selectedColor: Colors.blue[100],
                checkmarkColor: Colors.blue[700],
                backgroundColor: Colors.grey[100],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.blue[700] : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? Colors.blue[400]! : Colors.grey[300]!,
                  ),
                ),
              );
            }).toList(),
          ),

        // Validation hint
        if (selectedBrandIds.isEmpty && availableBrands.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Selecciona al menos una marca',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}
