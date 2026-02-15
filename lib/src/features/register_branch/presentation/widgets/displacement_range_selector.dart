import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/displacement_range_entity.dart';
import 'package:motogo_frontend/src/core/widgets/catalog_selector_states.dart';

/// Widget for selecting multiple displacement ranges using chips.
///
/// Displays user-friendly labels (e.g., "Bajo (50-200cc)")
/// but stores the raw range values (BAJO, MEDIO, ALTO) for persistence.
class DisplacementRangeSelector extends StatelessWidget {
  /// List of available displacement ranges loaded from the API.
  final List<DisplacementRangeEntity> availableRanges;

  /// List of selected range values (e.g., ["BAJO", "MEDIO"]).
  final List<String> selectedRanges;

  /// Callback when range selection changes.
  final ValueChanged<List<String>> onChanged;

  /// Whether the widget is enabled for interaction.
  final bool enabled;

  /// Whether ranges are currently loading.
  final bool isLoading;

  /// Optional error message to display.
  final String? errorMessage;

  const DisplacementRangeSelector({
    super.key,
    required this.availableRanges,
    required this.selectedRanges,
    required this.onChanged,
    this.enabled = true,
    this.isLoading = false,
    this.errorMessage,
  });

  void _toggleRange(String range) {
    if (!enabled) return;

    final newList = List<String>.from(selectedRanges);
    if (newList.contains(range)) {
      newList.remove(range);
    } else {
      newList.add(range);
    }
    onChanged(newList);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rangos de Cilindraje que atiende',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        // Loading state
        if (isLoading)
          const CatalogLoadingState()
        // Error state
        else if (errorMessage != null)
          CatalogErrorState(message: errorMessage!)
        // Empty state
        else if (availableRanges.isEmpty)
          const CatalogEmptyState(
            message: 'No hay rangos de cilindraje disponibles',
          )
        // Normal state with ranges
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableRanges.map((rangeEntity) {
              final isSelected = selectedRanges.contains(rangeEntity.range);
              return FilterChip(
                label: Text(rangeEntity.displayLabel),
                selected: isSelected,
                onSelected: enabled
                    ? (_) => _toggleRange(rangeEntity.range)
                    : null,
                selectedColor: Colors.green[100],
                checkmarkColor: Colors.green[700],
                backgroundColor: Colors.grey[100],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.green[700] : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? Colors.green[400]! : Colors.grey[300]!,
                  ),
                ),
              );
            }).toList(),
          ),

        // Hint text (optional — no validation required)
        if (selectedRanges.isEmpty && availableRanges.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Opcional: selecciona los rangos de cilindraje que atiende tu sede',
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
