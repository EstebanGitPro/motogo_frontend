import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/branch_type_entity.dart';
import 'package:motogo_frontend/src/core/constants/branch_constants.dart';

/// Dropdown widget for selecting establishment type.
///
/// Receives branch types from API instead of using hardcoded values.
class BranchTypeDropdown extends StatelessWidget {
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final bool enabled;
  final List<BranchTypeEntity> branchTypes;
  final bool isLoading;
  final String? errorMessage;

  const BranchTypeDropdown({
    super.key,
    this.selectedValue,
    required this.onChanged,
    this.enabled = true,
    required this.branchTypes,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return InputDecorator(
        decoration: _buildDecoration(),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.blue[400],
              ),
            ),
            const SizedBox(width: 12),
            const Text(BranchConstants.loadingTypes),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return InputDecorator(
        decoration: _buildDecoration().copyWith(errorText: errorMessage),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[400], size: 20),
            const SizedBox(width: 12),
            const Text(BranchConstants.errorLoadingTypes),
          ],
        ),
      );
    }

    // Only use selectedValue if it matches an item in the list
    final effectiveValue = branchTypes.any((t) => t.code == selectedValue)
        ? selectedValue
        : null;

    return DropdownButtonFormField<String>(
      value: effectiveValue,
      decoration: _buildDecoration(),
      items: branchTypes.map((type) {
        return DropdownMenuItem(value: type.code, child: Text(type.label));
      }).toList(),
      onChanged: enabled ? onChanged : null,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return BranchConstants.typeRequired;
        }
        return null;
      },
    );
  }

  InputDecoration _buildDecoration() {
    return InputDecoration(
      labelText: BranchConstants.establishmentTypeLabel,
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
    );
  }
}
