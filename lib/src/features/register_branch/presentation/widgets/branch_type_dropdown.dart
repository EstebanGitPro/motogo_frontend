import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';

/// Dropdown widget for selecting establishment type.
class BranchTypeDropdown extends StatelessWidget {
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  const BranchTypeDropdown({
    super.key,
    this.selectedValue,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      // ignore: deprecated_member_use
      value: selectedValue,
      decoration: InputDecoration(
        labelText: 'Tipo de Establecimiento',
        prefixIcon: const Icon(Icons.store_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: EstablishmentType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(EstablishmentType.getDisplayName(type)),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor selecciona un tipo';
        }
        return null;
      },
    );
  }
}
