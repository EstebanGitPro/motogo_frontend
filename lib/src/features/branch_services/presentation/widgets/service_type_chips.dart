import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/constants/service_constants.dart';

/// Widget displaying filter chips for service types.
///
/// Shows a horizontal scrollable list of chips for filtering
/// services by type (Todos, Mantenimiento, Reparación, etc.)
class ServiceTypeChips extends StatelessWidget {
  final String? selectedType;
  final ValueChanged<String?> onTypeSelected;

  const ServiceTypeChips({
    super.key,
    this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: ServiceConstants.allServiceTypes.map((type) {
          final isSelected =
              (selectedType == null && type == ServiceConstants.filterAll) ||
              selectedType == type;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (_) {
                if (type == ServiceConstants.filterAll) {
                  onTypeSelected(null);
                } else {
                  onTypeSelected(type);
                }
              },
              selectedColor: Colors.blue[100],
              checkmarkColor: Colors.blue[700],
              labelStyle: TextStyle(
                color: isSelected ? Colors.blue[700] : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected ? Colors.blue : Colors.grey[300]!,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
